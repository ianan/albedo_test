pro ospex_rhessi_drm_extract
  compile_opt idl2

  ; Minimal OSPEX setup: load spec + DRM, no model setup or fitting.
  fdir = 'fits/'
  fspec = 'hsi_spectrum_20021005_0938_1114_3_250keV_alld.fits'
  fsrm = 'hsi_srm_20021005_1040_1056_3_250keV_alld.fits'

  ; Keep this non-interactive for script use.
  set_logenv, 'OSPEX_NOINTERACTIVE', '1'

  o = ospex()
  o.set, spex_autoplot_enable = 0
  o.set, spex_fitcomp_plot_resid = 0
  o.set, spex_fit_progbar = 0
  o.set, spex_specfile = fdir + fspec
  o.set, spex_drmfile = fdir + fsrm

  ; Set time intervals so data products are fully initialized.
  o.set, spex_fit_time_interval = ['05-Oct-2002 10:41:20', '05-Oct-2002 10:42:24']
  o.set, spex_bk_time_interval = ['05-Oct-2002 10:38:32', '05-Oct-2002 10:40:32']

  ; Extract DRM and axes directly from the spex_drm class.
  drm = o.getdata(class = 'spex_drm', /force)
  ph_edges = o.get(/spex_drm_ph_edges, class = 'spex_drm')
  ct_edges = o.get(/spex_drm_ct_edges, class = 'spex_drm')
  area = o.get(/spex_drm_area, class = 'spex_drm')

  ; Convert edges to 2-column bins if needed.
  if (n_elements(size(ph_edges, /dimensions)) eq 1) then ph_edges = get_edges(ph_edges, /edges_2)
  if (n_elements(size(ct_edges, /dimensions)) eq 1) then ct_edges = get_edges(ct_edges, /edges_2)

  photon_bins = transpose(ph_edges)
  count_bins = transpose(ct_edges)
  dE_ph = get_edges(ph_edges, /width)
  dE_ct = get_edges(ct_edges, /width)

  print, 'OSPEX DRM extraction (no fitting):'
  print, '  SRM/DRM dims      : ', size(drm, /dimensions)
  print, '  photon_bins dims  : ', size(photon_bins, /dimensions)
  print, '  count_bins dims   : ', size(count_bins, /dimensions)
  print, '  photon widths dims: ', size(dE_ph, /dimensions)
  print, '  count widths dims : ', size(dE_ct, /dimensions)
  print, '  area              : ', area

  print, ''
  print, 'First 5 photon bins [keV]:'
  print, photon_bins[0:10, *]

  print, ''
  print, 'First 5 count bins [keV]:'
  print, count_bins[0:10, *]

  stop
end
