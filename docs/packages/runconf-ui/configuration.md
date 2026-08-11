# System Configuration

Runconf-UI uses a YAML file to determine what components are visible to the user. These files should be stored at:

```
[your_repo]/runconf-ui-settings/[apparatus].yml
```

---

## Sections

The configuration file has three top-level sections:



1. **Settings** — points to the classes you want made visible in the main system tree.


2. **PanelOptions** — lists the enable/disable panels.


3. **AdjustableAttributes** — lists things you want made adjustable, such as trigger rates.

---

## PanelOptions

Each panel in `PanelOptions` generates a tab in the TUI. There are three kinds of objects you can list under each panel's systems:

- **`components`** — objects that can be enabled/disabled by OKS directly.
- **`attributes`** — attributes of objects in OKS (e.g. the `TPG` attribute of a `ReadoutApplication`).
- **`relationships`** — relationships between objects in OKS that may need to be swapped.

### Full YAML Reference

```yaml
Settings:
    classes_to_show:  # List of classes to show on map panels
        - ClassName

PanelOptions:
    Panel:                       # Panel ID (unique key)
        label:                   # Display label for this panel [str]
        view_panel:              # Display name for the attribute map [str]

        systems:
          - SystemA:             # System name

              subsystem_dependent: false   # If true, system is off only when ALL subsystems are off [bool]
              display_full_system: true    # Include a button for the entire system [bool]

              components:
                - id:                      # Component ID (or substring when each_component_separate is true) [str]
                  class:                   # Component class in OKS [str]

                  # Optional
                  separate_system: false   # Does this component comprise its own subsystem button? [bool]
                  system_label:            # Label of that subsystem [str]
                  each_component_separate: false  # Generate one button per matching component [bool]
                  filters:                 # Exclude components by attribute value
                    - attribute:           # Attribute name [str]
                      values:              # Values to exclude [List[Any]]
                  tooltip:                 # Attribute name to use as tooltip, e.g. "description" [str]

              attributes:
                - id:                      # Attribute name [str]
                  class:                   # Class of objects with this attribute [str]
                  segments:                # Segments to search for objects in [List[str]], default ["root-segment"]

                  # Optional
                  enabled_state:           # Value representing enabled (default: true)
                  disabled_state:          # Value representing disabled (default: false)
                  system_label:            # Subsystem label [str]
                  separate_system: false   # [bool]
                  tooltip:                 # Tooltip string (printed directly when separate_system is true) [str]

              relationships:
                - id:                      # Attribute name of the relationship [str]
                  class:                   # Class of objects holding the relationship [str]
                  segments:                # [List[str]], default ["root-segment"]
                  relationship_class:      # Expected class of the related object [str]
                  enabled_state:           # DAL id(s) to relate when enabled [str | List[str]]
                  disabled_state:          # DAL id(s) to relate when disabled [str | List[str]]

AdjustableAttributes:
    AttributeGroup:              # Group name (becomes a tab)
        - label:                 # Internal label [str]
          Systems:
            - object_id:         # ID of the object (omit to match all objects of the class) [str, optional]
              object_class:      # Class of objects with this attribute [str]
              attribute_name:    # Name of the attribute to modify [str]
              is_hex: false      # Is the attribute stored in hex? [bool, optional]
              tooltip:           # Attribute to use as tooltip, e.g. "description" [str, optional]
              filters:
                - attribute:     # Attribute to filter by [str]
                  values:        # Values to exclude [List[Any]]
```

---

## Components in Detail

### `each_component_separate`

When set to `true`, runconf-ui finds **every** object in the configuration that:



1. Is of class `class` (including subclasses).


2. Has an `id` containing the given substring (use `""` to match all).


3. Does not match any of the `filters`.

Each matching object gets its own button.

```yaml
components:
  - id: ""
    class: CTBHLT
    each_component_separate: true
    filters:
      - attribute: description
        values: ["Spare", "spare"]
```

### `subsystem_dependent` and `separate_system`

Use these together to build hierarchical buttons. In the example below, TPC is the top-level system and CRP4/CRP5 are individually controllable subsystems:

```yaml
- TPC:
    subsystem_dependent: true

    components:
      - id: tpc-segment
        class: Segment

      - id: crp4-segment
        class: Segment
        system_label: CRP4
        separate_system: true

      - id: crp5-segment
        class: Segment
        system_label: CRP5
        separate_system: true
```

This generates three buttons: **TPC**, **CRP4**, and **CRP5**. Because `subsystem_dependent` is `true`, the TPC button becomes disabled only when both CRP4 and CRP5 are disabled.

---

## Multi-System Panels

A panel can contain multiple systems. Each system generates its own set of buttons under the same tab. For example, a Trigger panel might group TPC TPG and PDS TPG together:

```yaml
Trigger:
  label: "trigger"
  view_panel: "Trigger View"

  systems:
    - TPC TPG:
        attributes:
          - id: tp_generation_enabled
            segments: ["tpc-segment", "crp4-segment", "crp5-segment"]
            class: ReadoutApplication
          - id: ta_generation_enabled
            segments: ["tpc-segment", "crp4-segment", "crp5-segment"]
            class: ReadoutApplication
        components:
          - id: tc-maker-tpc
            class: TriggerApplication

    - PDS TPG:
        attributes:
          - id: tp_generation_enabled
            segments: ["pds-segment"]
            class: ReadoutApplication
```

---

## AdjustableAttributes

Adjustable attributes let the user set values (not just on/off) before a run — for example trigger rates:

```yaml
AdjustableAttributes:
  TriggerRates:
    - label: tc_rate
      Systems:
        - object_class: TriggerApplication
          attribute_name: trigger_rate
          tooltip: description
          filters:
            - attribute: description
              values: ["Spare"]
```

The adjustable panel shows the object name and attribute on the left and the current value on the right. **Apply** commits the new value; **Reset** reverts to the value loaded from the configuration file.

> **Note:** If the object containing an adjustable element is disabled, the controls will be greyed out and non-interactive.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Henry Wallace_

_Date: Thu Apr 9 12:26:14 2026 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/runconf-ui/issues](https://github.com/DUNE-DAQ/runconf-ui/issues)_
</font>
