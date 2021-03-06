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

pro arm_batch1, temp_path, output_path
    
    set_plot, 'z'

; Find todays date and convert to yyyymmdd format

    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
    utc = strmid( anytim( utc, /vms ), 0, 17 )

; Calculate the previous and next days date.

    calc_date, date, -1, prev_date
    calc_date, date,  1, next_date
    date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc }
    print, 'Done date stuff'

; Read the actddive region summary for the requested and previous days.
	
    print, 'getting srs'        
    get_srs, date_struct, srs_today, srs_yesterday, issued, t_noaa
    print, 'done getting srs'
	
; Get latest events from SSW database	    
  
    print, 'concating AR summary'
    last_events2arm2, date_struct, events
    print, 'done concating AR summary'

; Concat AR summary and events list for today and yesterday

    print, 'doing ar comb'
    ar_comb, date_struct, srs_today, srs_yesterday, events, summary, no_region_today, no_region_yesterday
    region_struct = { summary : summary, issued : issued, t_noaa : t_noaa }
    print, 'done ar_comb'

; Write a png for the GOES/RHESSI lightcurves

    print, 'Doing hhsi_obs_times'
 
    ;if ( float( strmid( anytim( utc, /time, /vms ), 0, 2 ) ) lt 4. ) then $
    ;          hhsi_obs_times, /print, $
    ;                          timerange = anytim([anytim(  utc ) - 24. * 60. *60., anytim( utc ) ],/date), $
    ;                         filename = output_path + '/data/' + prev_date + $
    ;                                     '/pngs/gxrs/gxrs_rhessi_' + prev_date + '.png'

    ;hhsi_obs_times, /print, timerange = anytim([anytim(  utc), anytim( utc ) + 24. * 60. * 60. ],/date), $
    ;                 filename = output_path + '/data/' + date + '/pngs/gxrs/gxrs_rhessi_' + date + '.png'  
       
    print, 'Done hsi_obs_times'

; Generate a web page for H-alpha, MDI continuum & magnetogram, EIT EUV,
; and GONG+ images. Also generate the transfer page, index, news, and
; forecast pages.

print,'Starting GONG ...'    
    arm_fd, output_path, date_struct, summary, gong_map_struct, /gong_maglc
print,'Done GONG ... starting 195'
    arm_fd, output_path, date_struct, summary, eit195_map_struct, /seit_00195
print,'Done 195 ... starting 284'
    arm_fd, output_path, date_struct, summary, eit284_map_struct, /seit_00284
    arm_fd, output_path, date_struct, summary, wl_map_struct, /smdi_igram, error_status=error_status_smdi_igram
    arm_fd, output_path, date_struct, summary, mag_map_struct, /smdi_maglc
    arm_fd, output_path, date_struct, summary, ha_map_struct, /bbso_halph, error_status=error_status_bbso_halph
    
    arm_fd, output_path, date_struct, summary, eit171_map_struct, /seit_00171
    
    arm_fd, output_path, date_struct, summary, eit304_map_struct, /seit_00304
    arm_fd, output_path, date_struct, summary, sxig12_map_struct, /gsxi        
    arm_fd, output_path, date_struct, summary, trce_mosaic171_map_struct, /trce_m0171

; Create the thumbnails

    print, 'Doing Thumbs: ' + 'perl process_thumbs.pl ' + date
    spawn, '/usr/bin/perl /Users/solmon/Sites/idl/process_thumbs.pl ' + date
    print, 'Done Thumbs: '

; Extract each region and write a web page for each

    arm_regions, output_path, date_struct, summary, gong_map_struct, /gong_maglc
    arm_regions, output_path, date_struct, summary, eit195_map_struct, /seit_00195
    arm_regions, output_path, date_struct, summary, eit284_map_struct, /seit_00284
    if ( error_status_smdi_igram eq 0 ) then $
         arm_regions, output_path, date_struct, summary, wl_map_struct, /smdi_igram
    arm_regions, output_path, date_struct, summary, mag_map_struct, /smdi_maglc
    if ( error_status_bbso_halph eq 0 ) then $
         arm_regions, output_path, date_struct, summary, ha_map_struct, /bbso_halph
    arm_regions, output_path, date_struct, summary, eit171_map_struct, /seit_00171
    arm_regions, output_path, date_struct, summary, eit304_map_struct, /seit_00304
    arm_regions, output_path, date_struct, summary, sxig12_map_struct, /gsxi        
    arm_regions, output_path, date_struct, summary, trce_mosaic171_map_struct, /trce_m0171
	
; Get the region page titles
   
    print, 'generating meta data'
    arm_ar_titles, output_path, date_struct, summary
    arm_ar_table, output_path, date_struct, summary
    arm_times, output_path, date_struct, issued
    arm_na_events, output_path, date_struct, no_region_today, no_region_yesterday
    mmmotd2arm, output_path, date_struct
    
    print, 'done generating meta data'

; Get the recent goes plots

    get_goes_plots, temp_path, output_path, date
    get_goes_events, temp_path, output_path, date

; Execute the forecast last as its prone to crashing

    arm_forecast, output_path, date_struct, summary

end
