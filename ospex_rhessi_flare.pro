pro ospex_rhessi_flare

; Testing the fit in ospex
;
; 06-Jul-2026 IGH


ftims=['05-Oct-2002 10:41:20','05-Oct-2002 10:42:24']
btims=['05-Oct-2002 10:38:32','05-Oct-2002 10:40:32']

fdir = "fits/"
fspec="hsi_spectrum_20021005_0938_1114_3_250keV_alld.fits"
fsrm="hsi_srm_20021005_1040_1056_3_250keV_alld.fits"

tmk2kev = 0.086164
fitstart = [1e-3,1.5,1,1e-2,6,1000,20,15,1000]

set_logenv, 'OSPEX_NOINTERACTIVE', '1'
o = ospex()
o.set, spex_fit_manual=0, spex_fit_reverse=0, spex_fit_start_method='previous_int'
o.set, spex_autoplot_enable=0, spex_fitcomp_plot_resid=0, spex_fit_progbar=0

o.set, fit_function = 'vth+thick2'
o.set, fit_comp_spectrum = ['full', '']
o.set, fit_comp_model = ['chianti', '']

o.set, spex_uncert = 0.0
o.set, mcurvefit_itmax = 50
o.set, mcurvefit_tol = 1e-4
o.set, spex_specfile = fdir+fspec
o.set, spex_drmfile = fdir+fsrm
o.set, spex_bk_order = 0

o.set, spex_fit_time_interval = ftims
o.set, spex_bk_time_interval = btims

xy=o.get(/spex_source_xy)
print,xy
o.set, spex_albedo_correct=1, spex_anisotropy=1.0, spex_source_xy=xy
print,o.get(/spex_source_angle) 
;; or can see it via gui
;o.xalbedo

o.set, spex_erange = [6, 15]
o.set, fit_comp_free = [1, 1, 0, 0, 0, 0, 0, 0, 0]
o.set, fit_comp_param = fitstart
o.dofit

o.set, spex_erange = [15, 45]
o.set, fit_comp_free = [0, 0, 0, 1, 1, 0, 0, 1, 0]
o.dofit
o.set, spex_erange = [6, 45]
o.set, fit_comp_free = [1, 1, 0, 1, 1, 0, 0, 1, 0]
o.dofit

p = o.get(/spex_summ_params)
perr = o.get(/spex_summ_sigmas)
chisq = o.get(/spex_summ_chisq)

nnpow=1.6e-9*p[3]*1e35*p[7]*(p[4]-1)/(p[4]-2)
titstr=string(p[1] / tmk2kev, format = '(f5.2)')+', '+$
    string(p[0] * 1e3, format = '(f5.2)')+'e46, '+$
    string(p[4], format = '(f5.2)')+', '+string(p[7], format = '(f5.2)')+$
    ', '+string(nnpow*1e-26, format = '(f5.2)')+'e26'

dd = o.getdata(class = 'spex_fitint', spex_units = 'rate')
fit = o.calc_func_components(spex_units = 'rate', /all_func)
ee = fit.ct_energy
de=ee[1,*]-ee[0,*]

chisq = o.get(/spex_summ_chisq)
mide = o.getaxis(/ct_energy)
erange = o.get(/spex_erange)

ftot = fit.yvals[*, 0]/de
fth = fit.yvals[*, 1]/de
fnn = fit.yvals[*, 2]/de
fal=ftot-fth-fnn

yr=[1e-2,1e4]
xr=[3,100]

; make plot look nice
clearplot
!y.style=17
!x.style=17
set_plot,'x';'win'
device,retain=2, decomposed=0
mydevice = !d.name
;; Make IDL use device/hardware fonts
!p.font = 0
!p.color = 255  ;255 for white line
!p.background = 0   ;0 for balck background
!p.thick = 1
!p.charthick = 1
!p.charsize = 1.
!p.symsize=1

; do the plot to eps
figname='ospex_fit.eps'
tlc_igh

set_plot, 'ps'
  device, /color, /isolatin1, /inches, /encapsulated,$
    bits = 8, xsize = 5, ysize = 4, file = figname
!p.thick=4
plot_oo, mide, dd.data/de, psym = 1, yrange = yr, ystyle = 17, xstyle = 17, xrange = xr, ytickf = 'exp1', $
    xtitle = 'Energy [keV]', ytitle = 'counts/s/keV', /nodata, title=titstr
nengs = n_elements(ee[0, *])
oploterr,  mide,dd.bkdata/de, de*0.5, dd.ebkdata/de, /nohat,psym=3,color=10,errcolor=10
oploterr,  mide,dd.data/de, de*0.5, dd.edata/de, /nohat,psym=3
oplot, erange, yr[1]*0.9*[1,1],thick=7,color=28

oplot, mide, fal, color = 127, psym = 10
oplot, mide, fth, color = 19, psym = 10
oplot, mide, fnn, color = 26, psym = 10
oplot, mide, ftot, color = 27, psym = 10

xyouts, 3e3, 4.1e3, 'vth', /device, color = 19,chars=1.2
xyouts, 3e3, 3.4e3, 'thick2', /device, color = 26,chars=1.2
xyouts, 3e3, 2.7e3, 'data-back', /device, color = 0,chars=1.2
xyouts, 3e3, 2e3, 'back', /device, color = 10,chars=1.2
xyouts, 4.2e3, 2e3, 'albedo', /device, color = 127,chars=1.2

device, /close
set_plot, mydevice
;; then convert to pdf...
;convert_eps2pdf, figname, /del

stop
end