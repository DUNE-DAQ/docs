# Python trgtools Module

Reading a DUNE-DAQ HDF5 file for the TP, TA, and TC contents can be easily done using the `trgtools` Python module.

# Example

## Common Methods
```python
import trgtools

tp_data = trgtools.TPReader(hdf5_file_name)

# Get all the available paths for TPs in this file.
frag_paths = tp_data.get_fragment_paths()

# Read all fragment paths. Appends results to tp_data.tp_data.
tp_data.read_all_fragments()

# Read only one fragment. Return result and append to tp_data.tp_data.
frag0_tps = tp_data.read_fragment(frag_paths[0])

# Reset tp_data.tp_data. Keeps the current fragment paths.
tp_data.clear_data()

# Reset the fragment paths to the initalized state.
tp_data.reset_fragment_paths()
```

## Data Accessing
```python
tp_data = trgtools.TPReader(hdf5_file_name)
ta_data = trgtools.TAReader(hdf5_file_name)
tc_data = trgtools.TCReader(hdf5_file_name)

tp_data.read_all_fragments()
ta_data.read_all_fragments()
tc_data.read_all_fragments()

# Primary contents of the fragments
# np.ndarray with each index as one T*
tp_data.tp_data
ta_data.ta_data
tc_data.tc_data

# Secondary contents of the fragments
# List with each index as the TPs/TAs in the TA/TC
ta_data.tp_data
tc_data.ta_data

ta0_contents = ta_data.tp_data[0]
tc0_contents = tc_data.ta_data[0]
```
Data accessing follows a very similar procedure between the different readers. The TAReader and TCReader also contain the secondary information about the TPs and TAs that formed the TAs and TCs, respectively. For the `np.ndarray` objects, one can also specify the member data they want to access. For example,
```python
ta_data.ta_data['time_start']  # Returns a np.ndarray of the time_starts for all read TAs
```
The available data members for each reader can be used (and shown) with `tp_data.tp_dt`, `ta_data.ta_dt` and `ta_data.tp_dt`, and `tc_data.tc_dt` and `tc_data.ta_dt`.

Look at the contents of `*_dump.py` for more detailed examples of data member usage.

While using interactive Python, one can do `help(tp_data)` and `help(tp_data.read_fragment)` for documentation on their usage (and similarly for the other readers and plotters).

# Plotting
There is also a submodule `trgtools.plot` that features a class `PDFPlotter`. This class contains common plotting that was repeated between the `*_dump.py`. Loading this class requires `matplotlib` to be installed, but simply doing `import trgtools` does not have this requirement.

## Example
```python
import trgtools
from trgtools.plot import PDFPlotter

tp_data = trgtools.TPReader(file_to_read)

pdf_save_name = 'example.pdf'
pdf_plotter = PDFPlotter(pdf_save_name)

plot_style_dict = dict(title="ADC Peak Histogram", xlabel="ADC Counts", ylabel="Count")
pdf_plotter.plot_histogram(tp_data['adc_peak'], plot_style_dict)
```

By design, the `plot_style_dict` requires the keys `title`, `xlabel`, and `ylabel` at a minimum. More options are available to further change the style of the plot, and examples of this are available in the `*_dump.py`.

### Development
The common plots available in `PDFPlotter` is rather limited right now. At this moment, these plots are sufficient, but more common plotting functions can be added.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: aeoranday_

_Date: Tue Feb 27 17:46:11 2024 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trgtools/issues](https://github.com/DUNE-DAQ/trgtools/issues)_
</font>
