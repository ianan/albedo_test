#### Testing fixed legacy fitting in sunkit-spex

Using the "Legacy Examples" from the sunkit-spex [example gallery](https://sunkit-spex.readthedocs.io/en/latest/generated/gallery/index.html#legacy-examples)

- [x] [fitting_attenuated_RHESSI_spectra](fitting_attenuated_RHESSI_spectra.ipynb): Produces same results, and using custom model still shows the parameters properly (using the older approach) in the fit plot.
- [x] [fitting_NuSTAR_spectra-duncan2021](fitting_NuSTAR_spectra-duncan2021.ipynb): Produces same results, including the showing the parameters on the plot in the new way across 3 panels, and the $C$ scaling between detectors.
- [x] [fitting_NuSTAR_spectra-general](fitting_NuSTAR_spectra-general.ipynb): Produces same results, including the showing the parameters on the plot in the new way.
- [x] [fitting_NuSTAR_spectra-simultaneously](fitting_NuSTAR_spectra-simultaneously.ipynb): Produces same results, including the showing the parameters on the plot in the new way, and user defined model parameters still shown (using the older approach).
- [x] [fitting_custom_spectra](fitting_custom_spectra.ipynb): Produces same results, and using custom model still shows the parameters properly (using the older approach) in the fit plot.
- [x] [fitting_RHESSI_spectra](fitting_RHESSI_spectra.ipynb): Produces mostly same results, though MCMC is slightly different but more due to fit than fix and needed to update code to work with current (pre-fix) legacy version.
- [x] [fitting_STIX_spectra](fitting_STIX_spectra.ipynb): Produces similar results, including the showing the albedo component, parameters on the plot in the new way across 3 panels, and the $C$ scaling between detectors.
- [x] [fitting_NuSTAR_spectra-glesener2020](fitting_NuSTAR_spectra-glesener2020.ipynb): Produces same results, including the showing the parameters on the plot in the new way across 3 panels, and the $C$ scaling between detectors. *Updated fitter.py to better present the `thick_warm` parameters, as name in wrapper slightly different from `thick_fn`*