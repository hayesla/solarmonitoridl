;+
; project :	BBSO Active Region Monitor (ARM)
;
; Name    :	arm_batch
;
; Purpose :	IDL batch file to run 
;
; Syntax  :	arm_batch
;
; Inputs  :	none
;
; Examples:	IDL> arm_batch
;                
; Outputs :	index.html, halpha_fd.html, wl_fd.html, mag_fd.html,
;         		eit_fd.html, and a page for each region in the fomat
;         		RegionNumber.html
;
; Keywords:	None
;
; History :	Written 05-feb-2001, Peter Gallagher, BBSO
; 			2004-07-07 - Russ Hewett: cleaned up formatting
;
; Contact :    info@solarmonitor.org
;
;-

pro arm_batch, temp_path, output_path
    print,'THE TIME IS NOW '+systim(/utc)
    
    set_plot, 'z'

; Find todays date and convert to yyyymmdd format

    get_utc, utc, /ecs
    date_dir = (strsplit(utc,' ',/ext))[0]
    date = time2file(utc,/date)
    utc = strmid( anytim( utc, /vms ), 0, 17 )

; Calculate the previous and next days date.

    calc_date, date, -1, prev_date
    calc_date, date,  1, next_date
    date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc , date_dir: date_dir}
    print, 'Done date stuff'

; Directory where to save everything
    today_dir = output_path + date_struct.date_dir+'/'

; Retrieve any new bakeout dates

    didbakeout=execute('get_bakeout_dates',1,1)
    if not didbakeout then print,'BAKEOUT DATES FAILED!!! or crashed. DAMN IT GURMAN!!!'

; Read the active region summary for the requested and previous days.
    print, 'getting srs'        
    get_srs, date_struct, srs_today, srs_yesterday, issued, t_noaa,$
             output_path=today_dir
    print, 'done getting srs'
	
; Get latest events from SSW database	    
    print, 'concating AR summary'
    last_events2arm2, date_struct, events
    print, 'done concating AR summary'

; Concat AR summary and events list for today and yesterday
    if ( srs_today[ 0 ] ne 'No data' ) then begin
       print, 'doing ar comb'
       ar_comb, date_struct, srs_today, srs_yesterday, events, summary, $
                no_region_today, no_region_yesterday
       print, 'done ar_comb'
       
    endif else begin
       summary = 'No data'
    endelse

    region_struct = { summary : summary, issued : issued, t_noaa : t_noaa }

; Get the region page titles
    print, 'generating meta data'
  
    if ( summary[ 0 ] ne 'No data' ) then begin
       arm_ar_titles, today_dir, date_struct, summary
       arm_ar_table,  today_dir, date_struct, summary
       arm_na_events, today_dir, date_struct, no_region_today, $
                      no_region_yesterday
    endif

  arm_times, today_dir, date_struct, issued
    
  print, 'done generating meta data'

; Get the recent GOES Plots
  get_goes_plots, temp_path, today_dir, date
  get_goes_events, temp_path, today_dir, date

; Get the latest ACE Plots
  get_ace, output_path=output_path, date_str=date_struct, /latest
  
; Get the latest SDO/EVE Plots

  get_eve,output_path=output_path, date_str=date_struct, /latest

; Write a png for the GOES/RHESSI lightcurves

    ;print, 'Doing hhsi_obs_times
 
    ;if ( float( strmid( anytim( utc, /time, /vms ), 0, 2 ) ) lt 4. ) then $
    ;          hhsi_obs_times, /print, $
    ;                          timerange = anytim([anytim(  utc ) - 24. * 60. *60., anytim( utc ) ],/date), $
    ;                         filename = output_path + '/data/' + prev_date + $
    ;                                     '/pngs/gxrs/gxrs_rhessi_' + prev_date + '.png'

    ;hhsi_obs_times, /print, timerange = anytim([anytim(  utc), anytim( utc ) + 24. * 60. * 60. ],/date), $
    ;                 filename = output_path + '/data/' + date + '/pngs/gxrs/gxrs_rhessi_' + date + '.png'

    ;print, 'Done hsi_obs_times'

; Generate a web page for H-alpha, MDI continuum & magnetogram, EIT EUV,
; and GONG+ images. Also generate the transfer page, index, news, and
; forecast pages.

crashed=''
error_status_seit_00195=1 & error_status_smdi_igram=1 & error_status_smdi_maglc=1 & error_status_gong_igram=1 & error_status_bbso_halph=1
error_status_gong_farsd=1 & error_status_slis_chrom=1 & error_status_stra_00195=1 & error_status_strb_00195=1 & error_status_swap_00174=1
error_status_saia_00171=1 & error_status_saia_00304=1 & error_status_saia_00193=1 & error_status_saia_04500=1 & error_status_saia_00094=1
error_status_saia_00131=1 & error_status_saia_00211=1 & error_status_saia_00335=1 & error_status_saia_01600=1
error_status_saia_01700=1 & error_status_shmi_maglc=1

    didswap=execute('arm_fd, output_path, date_struct, summary, swap174_map_struct, /swap_00174, error_status=error_status_swap_00174',1,1) 
didhxrt=0
    didhxrt=execute('arm_fd, output_path, date_struct, summary, hxrt_map_struct, /hxrt_flter',1,1) 
;    dide195=execute('arm_fd, output_path, date_struct, summary, eit195_map_struct, /seit_00195, error_status=error_status_seit_00195',1,1) 
;    dide284=execute('arm_fd, output_path, date_struct, summary, eit284_map_struct, /seit_00284',1,1) 
;    didmigr=execute('arm_fd, output_path, date_struct, summary, wl_map_struct, /smdi_igram, error_status=error_status_smdi_igram',1,1) 
;    didmmag=execute('arm_fd, output_path, date_struct, summary, mag_map_struct, /smdi_maglc, error_status=error_status_smdi_maglc',1,1) 
;    dide171=execute('arm_fd, output_path, date_struct, summary, eit171_map_struct, /seit_00171',1,1) 
;    dide304=execute('arm_fd, output_path, date_struct, summary, eit304_map_struct, /seit_00304',1,1) 
    didt171=execute('arm_fd, output_path, date_struct, summary, trce_mosaic171_map_struct, /trce_m0171',1,1) 
    didgmag=execute('arm_fd, output_path, date_struct, summary, gong_map_struct, /gong_maglc',1,1) 
    didgigr=execute('arm_fd, output_path, date_struct, summary, gongint_map_struct, /gong_igram, error_status=error_status_gong_igram',1,1) 
    didbbso=execute('arm_fd, output_path, date_struct, summary, ha_map_struct, /bbso_halph, error_status=error_status_bbso_halph',1,1) 
	didgfar=execute('arm_fd, output_path, date_struct, summary, gongfar_map_struct, /gong_farsd, error_status=error_status_gong_farsd',1,1) 
	didslis=execute('arm_fd, output_path, date_struct, summary, slischrom_map_struct, /slis_chrom, error_status=error_status_slis_chrom',1,1) 
	didstra=execute('arm_fd, output_path, date_struct, summary, stereoa_map_struct, /stra_00195, error_status=error_status_stra_00195',1,1) 
	didstrb=execute('arm_fd, output_path, date_struct, summary, stereob_map_struct, /strb_00195, error_status=error_status_strb_00195',1,1)

;Free up all the LUN's used in ARM_BATCH etc.
	free_lun,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31, $
		32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61, $
		62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91, $
		92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115, $
		116,117,118,119,120,121,122,123,124,125,126,127,128

	dids171=execute('arm_fd, output_path, date_struct, summary, saia171_map_struct, /saia_00171, error_status=error_status_saia_00171',1,1)
	dids304=execute('arm_fd, output_path, date_struct, summary, saia304_map_struct, /saia_00304, error_status=error_status_saia_00304',1,1)
	dids193=execute('arm_fd, output_path, date_struct, summary, saia193_map_struct, /saia_00193, error_status=error_status_saia_00193',1,1)
	did4500=execute('arm_fd, output_path, date_struct, summary, saia4500_map_struct, /saia_04500, error_status=error_status_saia_04500',1,1)
	dids094=execute('arm_fd, output_path, date_struct, summary, saia94_map_struct, /saia_00094, error_status=error_status_saia_00094',1,1)
	dids131=execute('arm_fd, output_path, date_struct, summary, saia131_map_struct, /saia_00131, error_status=error_status_saia_00131',1,1)
	dids211=execute('arm_fd, output_path, date_struct, summary, saia211_map_struct, /saia_00211, error_status=error_status_saia_00211',1,1)
	dids335=execute('arm_fd, output_path, date_struct, summary, saia335_map_struct, /saia_00335, error_status=error_status_saia_00335',1,1)
	did1600=execute('arm_fd, output_path, date_struct, summary, saia1600_map_struct, /saia_01600, error_status=error_status_saia_01600',1,1)
	did1700=execute('arm_fd, output_path, date_struct, summary, saia1700_map_struct, /saia_01700, error_status=error_status_saia_01700',1,1)
	didshmi=execute('arm_fd, output_path, date_struct, summary, shmimaglc_map_struct, /shmi_maglc, error_status=error_status_shmi_maglc',1,1)
;    didgsxi=execute('arm_fd, output_path, date_struct, summary, sxig12_map_struct, /gsxi',1,1) 

if not didhxrt then crashed=crashed+' XRT' & if not didt171 then crashed=crashed+' TRACE'
;if not dide195 then crashed=crashed+' EIT195' if not dide284 then crashed=crashed+' EIT284' & if not dide171 then crashed=crashed+' EIT171'
;if not didmmag then crashed=crashed+' MDIMAG' & if not didmigr then crashed=crashed+' MDIIGRAM'
;if not dide304 then crashed=crashed+' EIT304'
if not didgmag then crashed=crashed+' GONGMAG' & if not didgigr then crashed=crashed+' GONGIGRAM'
if not didbbso then crashed=crashed+' BBSO' & if not didgfar then crashed=crashed+' GONGFAR'
if not didslis then crashed=crashed+' SOLIS' & if not didstra then crashed=crashed+' STEREOA'
if not didstrb then crashed=crashed+' STEREOB'; & if not didgsxi then crashed=crashed+' GOESSXI'
if not didswap then crashed=crashed+' SWAP174' & if not dids171 then crashed=crashed+' AIA171'
if not dids304 then crashed=crashed+ ' AIA304' & if not dids193 then crashed=crashed+' AIA193'
if not did4500 then crashed=crashed+ ' AIA4500' & if not dids094 then crashed=crashed+' AIA94'
if not dids131 then crashed=crashed+' AIA131' & if not dids211 then crashed=crashed+' AIA211'
if not dids335 then crashed=crashed+' AIA335' & if not did1600 then crashed=crashed+' AIA1600'
if not did1700 then crashed=crashed+' AIA1700' & if not didshmi then crashed=crashed+ ' HMIMAGLC'

if crashed[0] eq '' then begin 
	print,'All Instruments have executed successfully! Score!'
	spawn,'echo "'+systim(/utc)+' No Crashes." > '+temp_path+'/arm_crash_summary.txt'
endif else begin
	print,'These instruments have crashed!: '+strjoin(crashed,' ') 
	spawn,'echo "'+systim(/utc)+' These instruments have crashed!: '+strjoin(crashed,' ')+'" > '+temp_path+'arm_crash_summary.txt'
endelse


; Create the thumbnails
;    print, 'Doing full-disk thumbs: ' + 'perl process_thumbs.pl ' + date
;    spawn, 'perl process_thumbs.pl ' + date, errpl
;    print, 'Done full-disk thumbs: '

; Extract each region and write a web page for each

  if ( summary[ 0 ] ne 'No data' ) then begin

regcrashed=''

	reghxrt=execute('if ( var_type(hxrt_map_struct) eq 8 ) then arm_regions, output_path, date_struct, summary, hxrt_map_struct, /hxrt_flter',1,1)
;    rege195=execute('if ( error_status_seit_00195 eq 0 ) then arm_regions, output_path, date_struct, summary, eit195_map_struct, /seit_00195',1,1)
;    rege284=execute('if ( var_type(eit284_map_struct) eq 8 ) then arm_regions, output_path, date_struct, summary, eit284_map_struct, /seit_00284',1,1)
;    regmigr=execute('if ( error_status_smdi_igram eq 0 ) then arm_regions, output_path, date_struct, summary, wl_map_struct, /smdi_igram',1,1)
;    regmmag=execute('if ( error_status_smdi_maglc eq 0 ) then arm_regions, output_path, date_struct, summary, mag_map_struct, /smdi_maglc',1,1)
;	rege171=execute('if ( var_type(eit171_map_struct) eq 8 ) then arm_regions, output_path, date_struct, summary, eit171_map_struct, /seit_00171',1,1)
;	rege304=execute('if ( var_type(eit304_map_struct) eq 8 ) then arm_regions, output_path, date_struct, summary, eit304_map_struct, /seit_00304',1,1)
	regt171=execute('if ( var_type(trce_mosaic171_map_struct) eq 8 ) then arm_regions, output_path, date_struct, summary, trce_mosaic171_map_struct, /trce_m0171',1,1)
	reggmag=execute('if ( var_type(gong_map_struct) eq 8 ) then arm_regions, output_path, date_struct, summary, gong_map_struct, /gong_maglc',1,1)
    reggigr=execute('if ( error_status_gong_igram eq 0 ) then arm_regions, output_path, date_struct, summary, gongint_map_struct, /gong_igram',1,1)
    regbbso=execute('if ( error_status_bbso_halph eq 0 ) then arm_regions, output_path, date_struct, summary, ha_map_struct, /bbso_halph',1,1)
	reggfar=execute('if ( error_status_gong_farsd eq 0 ) then arm_regions, output_path, date_struct, summary, gongfar_map_struct, /gong_farsd',1,1)
	regslis=execute('if ( error_status_slis_chrom eq 0 ) then arm_regions, output_path, date_struct, summary, slischrom_map_struct, /slis_chrom',1,1)
	regstra=execute('if ( error_status_stra_00195 eq 0 ) then arm_regions, output_path, date_struct, summary, stereoa_map_struct, /stra_00195',1,1)
	regstrb=execute('if ( error_status_strb_00195 eq 0 ) then arm_regions, output_path, date_struct, summary, stereob_map_struct, /strb_00195',1,1)
	regswap=execute('if ( error_status_swap_00174 eq 0 ) then arm_regions, output_path, date_struct, summary, swap174_map_struct, /swap_00174',1,1)
	regs171=execute('if ( error_status_saia_00171 eq 0 ) then arm_regions, output_path, date_struct, summary, saia171_map_struct, /saia_00171',1,1)
	regs304=execute('if ( error_status_saia_00304 eq 0 ) then arm_regions, output_path, date_struct, summary, saia304_map_struct, /saia_00304',1,1)
	regs193=execute('if ( error_status_saia_00193 eq 0 ) then arm_regions, output_path, date_struct, summary, saia193_map_struct, /saia_00193',1,1)
	reg4500=execute('if ( error_status_saia_04500 eq 0 ) then arm_regions, output_path, date_struct, summary, saia4500_map_struct, /saia_04500',1,1)
	regs094=execute('if ( error_status_saia_00094 eq 0 ) then arm_regions, output_path, date_struct, summary, saia94_map_struct, /saia_00094',1,1)
	regs131=execute('if ( error_status_saia_00131 eq 0 ) then arm_regions, output_path, date_struct, summary, saia131_map_struct, /saia_00131',1,1)
	regs211=execute('if ( error_status_saia_00211 eq 0 ) then arm_regions, output_path, date_struct, summary, saia211_map_struct, /saia_00211',1,1)
	regs335=execute('if ( error_status_saia_00335 eq 0 ) then arm_regions, output_path, date_struct, summary, saia335_map_struct, /saia_00335',1,1)
	reg1600=execute('if ( error_status_saia_01600 eq 0 ) then arm_regions, output_path, date_struct, summary, saia1600_map_struct, /saia_01600',1,1)
	reg1700=execute('if ( error_status_saia_01700 eq 0 ) then arm_regions, output_path, date_struct, summary, saia1700_map_struct, /saia_01700',1,1)
	regshmi=execute('if ( error_status_shmi_maglc eq 0 ) then arm_regions, output_path, date_struct, summary, shmimaglc_map_struct, /shmi_maglc',1,1)
;    arm_regions, output_path, date_struct, summary, sxig12_map_struct, /gsxi  

	if not reghxrt then regcrashed=regcrashed+' XRT' & if not regt171 then regcrashed=regcrashed+' TRACE'
;	if not rege195 then regcrashed=regcrashed+' EIT195' & if not rege284 then regcrashed=regcrashed+' EIT284'
;	if not regmmag then regcrashed=regcrashed+' MDIMAG' & if not regmigr then regcrashed=regcrashed+' MDIIGRAM'
;	if not rege171 then regcrashed=regcrashed+' EIT171' & if not rege304 then regcrashed=regcrashed+' EIT304'
	if not reggmag then regcrashed=regcrashed+' GONGMAG' & if not reggigr then regcrashed=regcrashed+' GONGIGRAM'
	if not regbbso then regcrashed=regcrashed+' BBSO' & if not reggfar then regcrashed=regcrashed+' GONGFAR'
	if not regslis then regcrashed=regcrashed+' SOLIS' & if not regstra then regcrashed=regcrashed+' STEREOA'
	if not regstrb then regcrashed=regcrashed+' STEREOB' & if not regswap then regcrashed=regcrashed+' SWAP174'
	if not regs171 then regcrashed=regcrashed+' AIA171' & if not regs304 then regcrashed=regcrashed+' AIA304'
	if not regs193 then regcrashed=regcrashed+' AIA193' & if not reg4500 then regcrashed=regcrashed+' AIA4500'
	if not regs094 then regcrashed=regcrashed+' AIA94' & if not regs131 then regcrashed=regcrashed+' AIA131'
	if not regs211 then regcrashed=regcrashed+' AIA211' & if not regs335 then regcrashed=regcrashed+' AIA335'
	if not reg1600 then regcrashed=regcrashed+' AIA1600' & if not reg1700 then regcrashed=regcrashed+' AIA1700'
	if not regshmi then regcrashed=regcrashed+' HMIMAGLC'

	if regcrashed[0] eq '' then begin
		spawn,'echo "'+systim(/utc)+' No region crashes." >> '+temp_path+'/arm_crash_summary.txt'
		print,'All Regions have executed successfully! Score!'
	endif else begin
		print,'These region instruments have crashed!: '+strjoin(regcrashed,' ')
		spawn,'echo "'+systim(/utc)+' These region instruments have crashed!: '+strjoin(regcrashed,' ')+'" >> '+temp_path+'/arm_crash_summary.txt'
	endelse

    ; Create the thumbnails
;        print, 'Doing AR zoom-in thumbs: ' + 'perl process_thumbs.pl ' + date
;        spawn, '/usr/bin/perl /Users/solmon/Sites/idl/process_thumbs.pl ' + date, errpl
;        print, 'Done AR zoom-in thumbs: '

  endif else spawn,'echo "'+systim(/utc)+' No regions." >>' +temp_path+'/arm_crash_summary.txt'

;** CHECK till here!	
; Do Ionosphere stuff

  didaurora=execute('get_aurora, date=date_struct.date, /write_meta, err=err, /forecast',1,1)
  didauroranowcast=execute('get_aurora, /write_meta, err=err, /nowcast',1,1)
  didionosphere=execute('get_ionosphere, /tec, /kyoto, /poes, /ovation, err=err',1,1)
  didpoesmovie=execute('get_poes_movie, /north, date=date_struct.date, err=err, outpath=output_path',1,1)
  ionomodule=''
  if not didaurora then ionomodule=ionomodule+' AURORA_FORECAST' & if not didauroranowcast then ionomodule=ionomodule+' AURORA_NOWCAST'
  if not didionosphere then ionomodule=ionomodule+' IONOSPHERE_PLOTS' & if not didpoesmovie then ionomodule=ionomodule+' POES_MOVIE'
  if ionomodule eq '' then spawn,'echo "'+systim(/utc)+' No ionosphere crashes." >> /Users/solmon/Sites/idl/arm_ionosphere_crash_summary.txt' $
	else spawn,'echo "'+systim(/utc)+' These IONOSPHERE Modules crashed: '+ionomodule+'" >> /Users/solmon/Sites/idl/arm_ionosphere_crash_summary.txt'

; Get the latest SOHO Movies

  arm_movies, output_path, date_struct
  
; Execute the forecast last as its prone to crashing

  if ( summary[ 0 ] ne 'No data' ) then arm_forecast, output_path, date_struct, summary

  mmmotd2arm, output_path, date_struct
 
end