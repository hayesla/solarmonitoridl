pro get_goes_events, temp_path, output_path, date

	strdate = strtrim(string(date),2)

	year = strmid(strdate,0,4)

	file = 'http://services.swpc.noaa.gov/text/solar-geophysical-event-reports.txt'

	sock_ping, 'services.swpc.noaa.gov', status

	if (status eq 1) then begin
           sock_copy, file,out_dir = temp_path, err = error
           if (error ne file + ' not found on server.') then begin
              file_move, temp_path + 'solar-geophysical-event-reports.txt', $
                         output_path +'/meta/noaa_events_raw_' + strdate  + '.txt',/overwrite
           endif

	endif
	

end
