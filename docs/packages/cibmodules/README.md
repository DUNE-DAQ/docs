# CIBModules: Calibration Interface Board Integration for DUNE DAQ

## Overview


**CIBModules** is a DUNE DAQ plugin package that provides a command and readout interface for the **Calibration Interface Board (CIB)** hardware. The CIB controls and operates the **Ionization Laser System (IoLS)** used for charge calibration in the DUNE detector. This module bridges detector calibration hardware with the DUNE DAQ framework, enabling synchronized trigger generation and detector readout.

### Purpose

The CIB hardware is a specialized hardware controller that manages:
- **Laser calibration system operation**: Controls ionization laser delivery and positioning
- **Detector trigger generation**: Produces trigger words that are then used by the DUNE DAQ to read out the detector
- **Motor control**: Manages three stepper motors for laser alignment and positioning
- **Timing and synchronization**: Coordinates with DUNE's timing and trigger system

CIBModules implements the DUNE DAQ interface to interface the CIB trigger functionality as a pluggable `DAQModule`. 
CIBModules handles the TCP communication with the CIB hardware, parses incoming trigger data, and translates it into DUNE's HSI (Hardware Signal Interface) format for subsequent trigger candidate generation and detector readout.

---

## Architecture & Design Principles

### High-Level Design

The CIBModule bridges two separate network connections:

- **Control connection** (ephemeral): CIBModule → CIB hardware (port 8992)
  - Used for JSON-formatted configuration commands
  - Blocks until response received, ensuring synchronization
- **Data connection** (persistent): CIB → CIBModule (port 8993 by default, but configurable)
  - Runs in dedicated worker thread with 70 ms receive timeout
  - Receives IoLS trigger detector data continuously during run
  - Parses incoming trigger packets, extracts motor positions and timestamps and produces HSI frames for DAQ backend

```
┌──────────────────────────────┐
│   DUNE DAQ Framework         │
│  (appfwk, iomanager)         │
└──────────────┬────────────────┘
               │
       ┌───────▼────────┐
       │  CIBModule     │  (HSIEventSender)
       │  DAQModule     │
       └───┬──────────┬─┘
           │          │
    ┌──────▼──┐   ┌───▼─────────┐
    │ Control │   │ Data Worker │
    │ Socket  │   │ Thread      │
    │ (JSON)  │   │ (TCP recv)  │
    └──────┬──┘   └───┬─────────┘
           │          │
    ┌──────▴──────────▴──┐
    │   CIB Hardware     │  (port 8992)
    │  (ZynqMP board)    │
    └────────────────────┘
```

### Key Design Principles



1. **Dual TCP Connection Pattern**
   - This decoupling prevents deadlocks and enables non-blocking trigger reception
   - Control channel remains responsive for stop commands even during heavy data flow



2. **HSI Frame Generation**
   - `CIBModule` inherits from `HSIEventSender` 
   - Converts incoming IoLS trigger packets to standardized HSI frames
   - Encodes trigger information (motor positions, timestamps) in HSI format
   - Sends frames to DAQ backend via IOManager sender for downstream processing



3. **Worker Thread Lifecycle**
   - Worker thread created but not started until `do_start()` is called
   - Thread runs socket listener accepting CIB connections and reading trigger data
   - Respects run state via `std::atomic<bool>` flags for lock-free synchronization
   - Cleanly shuts down on `do_stop()`, waiting for connection closure and socket EOF



4. **Graceful Shutdown Handshake**
   ```
   do_stop()
     ├─ Set m_stop_requested = true (signals data thread to stop accepting)
     ├─ Send {"command":"stop_run"} via control socket
     ├─ CIB closes data connection (TCP FIN)
     ├─ Receiver thread detects EOF, exits loop
     ├─ do_stop() awaits thread completion
     └─ Return response to DAQ framework
   ```



5. **Configuration-Driven Initialization**
   - Appmodel schema validation ensures required fields before startup
   - All connection parameters (host, port, timeout) configurable
   - Trigger bit mapping defines which HSI trigger index this receiver uses
   - Calibration stream settings enable offline data dumping for analysis
   - At nominal 10 Hz laser trigger rate, the calibration stream produces manageable file sizes (approx. 560 kB per hour)



6. **Thread Safety**
   - **Atomic flags** for state synchronization (`m_is_running`, `m_is_configured`, `m_stop_requested`)
   - **No locks in data path**: Single-threaded worker thread receives all data; main thread only reads atomic counters
   - **Shared mutex** for buffer count averaging (monitoring only)
   - **Exception-based error propagation** for command-phase errors (configure, start, stop)

---

## Components & Functionality

### CIBModule.hpp - Class Definition


**Primary class**: `CIBModule : public dunedaq::hsilibs::HSIEventSender`


**Key members**:
- `m_control_socket`: Boost ASIO TCP socket for JSON command/response exchange
- `m_receiver_socket`: Boost ASIO TCP socket receiving trigger data from CIB
- `m_receiver_ios`: Boost ASIO IO service context for async socket operations
- `m_thread_`: Worker thread (via `dunedaq::utilities::WorkerThread`)
- `m_cib_hsi_data_sender`: IOManager sender for HSI frames to downstream modules
- Atomic counters: `m_num_control_messages_sent`, `m_num_run_triggers_received`, etc.

### CIBModule.cpp - Implementation


**Lifecycle methods**:
- `CIBModule(name)`: Constructor initializing atomic flags and sockets
- `init(cfgMgr)`: Loads appmodel configuration; sets up HSI frame output sender
- `do_configure(obj)`: Connects to CIB hardware, establishes control socket, parses geo_id and trigger configuration
- `do_start(startobj)`: Launches worker thread, sets up receiver socket listener, sends "start_run" command
- `do_stop(obj)`: Sends "stop_run" command, awaits worker thread exit, closes sockets
- `~CIBModule()`: Cleanup (closes control socket if still open)


**Worker thread**:
- `do_hsi_work()`: Runs in dedicated thread for entire run duration
  - Sets up listener on port 8871, awaits CIB connection
  - Reads IoLS trigger packets in a loop
  - Parses 3-motor position data + timestamp from each packet
  - Constructs HSI_FRAME_STRUCT with trigger data
  - Sends HSI frame via m_cib_hsi_data_sender
  - Logs calibration data if enabled
  - Exits cleanly when EOF received or stop requested


**Utility methods**:
- `send_config(json_string)`: Sends configuration to CIB via control socket
- `send_message(json_string)`: Sends command to CIB, waits for response with 1 sec timeout
- `read<T>(socket, obj)`: Generic template method to read binary data from socket
- `parse_hex(string, uint32)`: Parses hex trigger bit string for HSI frame encoding
- `set_calibration_stream(prefix)`: Opens timestamped calibration file for trigger dumping
- `update_calibration_file()`: Rotates calibration file at configurable interval (default 15 min)

### CIBModuleIssues.hpp - Error Handling

Custom ERS (Error Reporting System) exception types for DUNE DAQ:
- `CIBCommunicationError`: Socket/network failures, timeouts
- `CIBConfigFailure`: Configuration parsing or appmodel missing fields
- `CIBModuleError`: Internal state violations, receiver setup failures
- `CIBWrongState`: State machine violations (e.g., start without configure)
- Message/warning/debug variants for non-fatal issues

### cib_data_fmt.h - Data Format Definitions

Struct definitions for IoLS trigger data exchange (shared with cib_utils):
- `iols_trigger_t`: Motor position data (m1, m2, m3 with 17-22 bit resolution) + timestamp
- `tcp_header_t`: Packet framing (version, sequence, size)
- `iols_tcp_packet_t`: Full packet = header + trigger payload
- Bitmask utilities for signed value extraction (handles motor position signedness)

### Configuration Schema


**File**: schema/cibmodules/cib_config.json

Provides defaults for JSON configuration:
```json
{
  "cib": {
    "sockets": {
      "receiver": {
        "host": "localhost",
        "port": 8992
      }
    },
    "trigger_bit": "0x4"
  }
}
```


**Appmodel schema**: [DUNE-DAQ/appmodel](https://github.com/DUNE-DAQ/appmodel/blob/develop/schema/appmodel/CIB.schema.xml)

OKS schema classes:
- `CIBModule`: Top-level DAQModule configuration (has `configuration` ↔ `CIBConf` and `board` ↔ `CIBoardConf`)
- `CIBConf`    : Connection parameters (host, port, timeout)
- `CIBoardConf`: Board identity and geo_id (detector_id, crate_id, slot_id), as well as receiver location (port)
- `CIBTrigger` : Trigger mapping (trigger_id, trigger_bit hex string, description)
- `CIBCalibrationStream`: Calibration output settings (directory, update period)

---

## Data Flow

### Configuration Phase
```
DAQ Manager sends config JSON
         ↓
do_configure() parses appmodel
         ↓
Extract CIB host/port/trigger bit
         ↓
Create Boost ASIO control socket → CIB:8992
         ↓
send_config() → JSON configuration message → CIB
         ↓
CIB acknowledges (sets m_is_configured = true)
```

### Run Execution
```
do_start() called with run number
         ↓
Launch worker thread do_hsi_work()
         ↓
Worker: Create listener socket on port 8993
         ↓
Worker: Signal m_receiver_ready = true
         ↓
Main thread: send_message({"command":"start_run", "run_number":N})
         ↓
CIB connects to port 8871, begins streaming triggers
         ↓
Worker: read() io-loops receiving IoLS trigger packets
         ↓
For each packet:
   - Extract motor positions (m1, m2, m3)
   - Get timestamp
   - Build HSI_FRAME_STRUCT
   - Send via m_cib_hsi_data_sender → downstream DAQ modules
   - Increment m_num_run_triggers_received
   - Optionally write to calibration file
         ↓
(main thread continues, allows other modules to run)
         ↓
do_stop() called
         ↓
send_message({"command":"stop_run"})
         ↓
CIB closes data socket (EOF on port 8871)
         ↓
Worker: read() returns false, exits loop
         ↓
Main: m_thread_.stop_working_thread() joins worker
         ↓
Return to DAQ (m_is_running = false)
```

### Calibration Stream (Optional)
- If enabled via configuration, worker thread opens timestamped file in `m_calibration_dir`
- Every trigger packet written as binary data to file
- File rotated at `m_calibration_file_interval` (default 15 min) to manage size
- Useful for offline trigger analysis, debugging laser performance

---

## Dependencies

### External Libraries

| Dependency | Role | Version |
|------------|------|---------|
| **Boost ASIO** | Async TCP networking (socket, resolver, endpoint) | Part of Boost 1.70+ |
| **nlohmann::json** | JSON parsing/generation for CIB commands | Header-only, v3.x+ |
| **DUNE appfwk** | DAQModule base class, ConfigurationManager | DUNE DAQ suite |
| **DUNE iomanager** | Sender/Receiver for module connectivity | DUNE DAQ suite |
| **DUNE hsilibs** | HSIEventSender base, HSI_FRAME_STRUCT | DUNE DAQ suite |
| **DUNE logging** | TLOG macros for structured logging | DUNE DAQ suite |
| **DUNE ers** | Exception/error reporting system | DUNE DAQ suite |
| **DUNE appmodel** | Configuration schema (DAL) for CIB parameters | DUNE DAQ suite |
| **spdlog** | Underlying logging backend | Indirect via DUNE |

### Internal Dependencies

- **cib_utils** (`cib_data_fmt.h`): Data structure definitions shared with CIB hardware and other CIB tools
- **appmodel** (`CIB.schema.xml`, generated DAL classes): Configuration object access

### Build System

- **CMake** 3.12+ (via `daq-cmake`)
- **Protobuf** codegen for monitoring metrics (`opmon/CIBModule.pb.h`)

---

## Configuration & Usage

### Module Configuration (Appmodel)

In OKS database configuration:

```xml
<CIBModule>
  <name>cib_receiver_0</name>
  <configuration class="CIBConf">
    <cib_host>np04-iols-cib-02.cern.ch</cib_host>
    <cib_port>8992</cib_port>
    <connection_timeout_ms>1000</connection_timeout_ms>
    <!-- Trigger mapping -->
    <cib_trigger class="CIBTrigger">
      <trigger_id>iols_laser</trigger_id>
      <trigger_bit>0x4</trigger_bit>
      <description>IoLS Laser Trigger</description>
    </cib_trigger>
    <!-- Optional calibration stream -->
    <calibration_stream class="CIBCalibrationStream">
      <output_directory>/data/cib_triggers</output_directory>
      <update_period_s>900</update_period_s>
    </calibration_stream>
  </configuration>
  <board class="CIBoardConf">
    <geo_id>
      <detector_id>1</detector_id>
      <crate_id>0</crate_id>
      <slot_id>4</slot_id>
    </geo_id>
  </board>
  <outputs>
    <connection UID="HSI_trigger_cib">
      <!-- HSI frame output to DAQ backend -->
    </connection>
  </outputs>
</CIBModule>
```

### Runtime Command Sequence



1. **Configure**: Frame sends configuration from appmodel → CIB hardware setup


2. **Start**: Worker thread launches, listens for CIB connection, DAQ tells CIB to start sending triggers


3. **Run**: Trigger data flows, HSI frames generated and shipped downstream


4. **Stop**: DAQ stops CIB streaming, worker thread exits, resources cleaned up

### Monitoring & Telemetry

Metrics tracked (via Protobuf opmon):
- `num_control_messages_sent`: Commands sent to CIB
- `num_control_responses_received`: Acknowledgments from CIB
- `num_total_triggers_received`: Cumulative trigger count
- `num_run_triggers_received`: Triggers in current run
- `hardware_running`: Boolean state
- `hardware_configured`: Boolean state
- `average_buffer_counts`: Average pending trigger queue depth

Accessible via DUNE's OpMon (operational monitoring) system for real-time diagnostics.

---

## Error Handling & Diagnostics

### Common Issues



1. **"Unable to connect to CIB"**
   - CIB hardware not running or wrong IP/port
   - Network connectivity check: `ping` CIB host, verify port 8992 open



2. **"Receiver socket timed out"**
   - CIB failed to connect within 500 ms (50 × 10 ms retries)
   - CIB may not have started data streaming; check CIB firmware logs



3. **"Listener port in use"**
   - Another process using port 8993
   - Increments port number in configuration and retry until find unused port
   - Updates configuration and sends new port to CIB via control socket



4. **"CIB has not been successfully configured"**
   - `do_start()` called without successful `do_configure()`
   - Verify configuration JSON sent and CIB acknowledged

### Logging

Set log level to debug for detailed execution trace:
```bash
export DUNEDAQ_LOG_LEVEL=debug
```

Output shows:
- Control socket connection attempts
- JSON messages sent/received
- Worker thread lifecycle events
- Trigger packet parsing details
- HSI frame construction

---

## Integration with DUNE DAQ Ecosystem

### Application Composition

CIBModule is one module in a DAQ application instance. Typical composition:

```
DAQ Application
├─ CIBModule (produces HSI frames)
├─ DataHandlerModule (ingests HSI frames, formats for detector readout)
├─ TriggerPrimitiveModule (optional: interprets trigger bits)
└─ Other modules (timing, monitoring, etc.)
```


**Data flow**: CIBModule → IOManager queue/network → DataHandlerModule → detector data formatting → storage

### HSI Integration

CIBModule extends `HSIEventSender`, meaning:
- Registers with IOManager as source of HSI trigger events
- Produces 128-bit HSI frames with:
  - 10-bit crate ID
  - 4-bit slot ID
  - 16-bit trigger bits (e.g., 0x0004 for laser trigger)
  - 64-bit timestamp
- Integrates with TPC trigger logic and timing system

### Appmodel Configuration Management

Leverages DUNE's configuration framework:
- **Schema validation** on load (ensures required fields present)
- **Dependency resolution** (board config validates geo_id)
- **Runtime reconfiguration** (supported; triggers `do_configure()` again)
- **Session awareness** (accesses session info for output directory paths)

---

## Testing & Development

### Unit Tests

Run via CMake:
```bash
cd build
ctest --output-on-failure
```

Current test coverage (minimal):
- Placeholder tests in `unittest/Placeholder_test.cxx`
- TODO: Full lifecycle tests, socket mocking, error injection

### Manual Testing (Standalone)

For development without full DAQ:


1. Mock CIB hardware with cib_utils `cib_daq_server` in simulation mode


2. Create test appmodel config with localhost addresses


3. Run DAQ shell with manual `conf`, `start`, `stop` commands

### Debug Targets

Appmodel generation:
```bash
# Regenerate C++ classes from schema (auto on build)
dune_oks_generate --schema schema/appmodel/CIB.schema.xml
```

---

## Code Quality & Standards

- **C++ Standard**: C++11 (minimum requirement per DUNE policy)
- **Naming conventions**:
  - Member variables: `m_` prefix (e.g., `m_receiver_port`)
  - Private/protected: lowercase with underscores
  - Public: camelCase methods
- **Resource management**: RAII with `std::unique_ptr`, `std::lock_guard` for locks
- **No raw pointers**: Prefer smart pointers; raw pointers only in appmodel DAL objects (managed by framework)
- **Linting**: Code follows DUNE's cpplint style (enforced in CI)

---

## Related Modules & Documentation

- **[appmodel](https://github.com/DUNE-DAQ/appmodel/)** Configuration schema and DAL generation
- **DUNE DAQ docs**: [dune-daq-sw.readthedocs.io](https://dune-daq-sw.readthedocs.io/)

---

## Authors & Acknowledgments


**Development team**:
- Nuno Barros (primary developer)
- DUNE Calibration Working Group

---

## License

This project is part of the DUNE DAQ Software Suite.
See the COPYING file in the root of the DUNE repository for full licensing details.

---

## Project Status


**Current Version**: 1.0.0


**Development Status**: Active

- ✅ Core functionality (trigger reception, HSI generation) stable
- ✅ Multi-motor position parsing and reporting
- ✅ Calibration stream offline dumping
- 🔄 Full test coverage (in progress)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Wed Feb 25 08:51:58 2026 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/cibmodules/issues](https://github.com/DUNE-DAQ/cibmodules/issues)_
</font>
