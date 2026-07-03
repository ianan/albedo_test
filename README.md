# albedo_test
Testing some albedo related things

We have
* $Ph_{M}$: the total photon flux model, i.e. thermal + non-thermal
* $D$: the DRM (or SRM)
* $A$: the albedo green matrix correction (https://github.com/edkontar/albedo)
* $C_{T}$: the total count flux model including albedo
* $C_{A}$: the albedo component in count flux - just used for plotting
* $I$:  the identity matrix

I think the following is correct....

#### ospex

How it is implemented in sswidl/ospex - as a pseudo function that modifies the DRM, i.e.
$$
    C_{T} = (D\#(I+A)^T)\#Ph_{M}
    \\
    \\
    C_{A} = (D\#(I+A)^T)\# Ph_{M}  - D \#Ph_{M} 
$$
Before April 2010 this was only applied at the start, but since then applied every call/fitting step, so can be either fixed correction or another component to fit - [more info on ospex help page.](https://hesperia.gsfc.nasa.gov/ssw/packages/spex/doc/ospex_explanation.htm#Albedo%20Correction). This is implemented in [object_spex/drm_correct_albedo.pro](https://hesperia.gsfc.nasa.gov/ssw/packages/spex/idl/object_spex/drm_correct_albedo.pro), line 206:
```
drm_albedo=one+Anew
drm_old=drm
drm=drm_old # transpose(drm_albedo)
```
This is then used in fitting via [object_spex/spex_drm__define.pro](https://hesperia.gsfc.nasa.gov/ssw/packages/spex/idl/object_spex/spex_drm__define.pro) line 854
```
yfit = self -> albedo(yfit, theta=theta, anisotropy=anis)
```
For plotting the albedo count component, it is the difference between the total photon model folded through the DRM with and without the albedo correction, i.e. $C_{A}$ above. This is in [object_spex/spex_gen__define.pro](https://hesperia.gsfc.nasa.gov/ssw/packages/spex/idl/object_spex/spex_gen__define.pro) about lines 1947, 1969 and 1981, i.e.
```
yv = fitobj -> getdata(strategy_name='')
; for photon output, call albedo method directly since need to supply the energy edges (yv here is on
; count edges, but default for albedo matrix is photon edges). Take difference of flux with albedo
; correction (yvfull) to without (yv) 
alb_params = fitobj -> get(/fit_comp_params,comp_name='albedo')  
anis=alb_params[0]
theta = self -> get(/spex_source_angle)
yvfull = (self->get(/obj,class='spex_drm')) -> albedo(yv, theta=theta, anisotropy=anis, energy=energy)
yv_alb = yvfull - yv
```

#### sunkit-spex (legacy)

How it is implemented in sunkit-spex legacy fitter - as an additional component to the photon model, i.e.
\[
    C_{T} = (Ph_{M} + Ph_{M}@A)@D
    \\
    \\
    C_{A} = (Ph_{M}@A)@D
\]
This seems to be done in `make_model()` and `albedo()` in [legacy/fitting/fitter.py](https://github.com/sunpy/sunkit-spex/blob/32c58fcc2d36cbe7d1f6416aa5c5e8e56250e529/sunkit_spex/legacy/fitting/fitter.py#L5658), i.e. line 5722 for the photon spectra that `albedo()` returns:
```
return spec + spec @ albedo_matrix, spec @ albedo_matrix
```
Then `make_model()` calculates and returns this in count space, i.e.:
```
albedo_excess_count = np.matmul(albedo_excess_phot, srm)

model_cts_spectrum = np.matmul(photon_spec, srm)

return model_cts_spectrum, albedo_excess_count
```

#### sunkit-spex (new)

Newer sunkit-spex fitting uses the same implementation (as using the same physical model in [models/physical/albedo.py](https://github.com/sunpy/sunkit-spex/blob/main/sunkit_spex/models/physical/albedo.py)) but for plotting calculates the albedo count component as difference, i.e.
\[
    C_{T} = (Ph_{M} + Ph_{M}@A)@D
    \\
    \\
    C_{A} = (Ph_{M} + Ph_{M}@A)@D - (Ph_{M}@D)
\]
The source code for this is [sunkit_spex/visulisation/plotter.py](https://github.com/sunpy/sunkit-spex/pull/271/files#diff-0f7161dff46f19d020a8beadaff0dbc75d5902baaa18ea754dd185ec5a1c5c5eR75) i.e. line 70, 71 then 75 does:
```
eval_noalbedo = ((((model['ThermalEmission'] + model['ThickTarget']) * 
    model['InverseSquareFluxScaling'] ) ) | model['SRM'])(photon_edges)
eval_albedo = ((((model['ThermalEmission'] + model['ThickTarget']) * 
    model['InverseSquareFluxScaling'] ) | model['Albedo'] ) | model['SRM'])(photon_edges)

albedo = eval_albedo - eval_noalbedo
```