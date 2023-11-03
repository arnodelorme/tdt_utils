% get tdt file properties
% -----------------------

% allchoices     - title choice
% suballchoices  - sub choice in Hz or freq. band
% allchoicesfull - same as allchoices with "by hz increment" or "by freq. band" text at the end

function [ fileinfo allchoices suballchoices allchoicesfull ] = gettdtcontent(filename, choice, subchoice);

    % find title
    % ----------
    fields = { 'name' 'subject_id' 'dob' 'age' 'gender' 'handedness' 'eeg_id' ...
               'date' 'time' 'technician' 'doctor' 'medication' 'epochlen' };	
    fieldtitle = { 'Name:' 'Subject ID:' 'Date of Birth:' 'Age:' 'Gender:' ...
        'Handedness:' 'EEG ID:' 'Date of Test:'	'Time of Test:'	'Technician:' ...
        'Doctor:' 'Medication:'	'Epoch Length (sec):' };
    count = 1;
    skip  = 0;
    fileinfo = [];
    fid = fopen(filename, 'r');
    if fid == -1, error(['Cannot open file ' filename]); end;
    while count <= length(fields) & ~feof(fid)
        tmpline = fgetl(fid);
        if ~isempty(tmpline)
            ind = findstr(fieldtitle{count}, tmpline);
            if isempty(ind),
                warning('No header or invalid header');
                fileinfo.epochlen = '1';
                fseek(fid, 0, -1);
                break;
            end;
            fileinfo = setfield( fileinfo, fields{count}, tmpline(length(fieldtitle{count})+1:end));
            count = count+1;
        end;
        skip = skip+1;
    end;
    fileinfo.epochlen = num2str(fileinfo.epochlen);
    
    % search for strings
    % ------------------
    shownextline = 0;
    nblines      = 0;
    count        = 1;
    while ~feof(fid)
        tmpline = fgetl(fid); % read one line
        nblines = nblines+1;
        if shownextline & nblines > 0 & ~isempty(tmpline)
            if tmpline(1) ~= 9
                allchoices{count} = tmpline;
                tmpline = fgetl(fid);
                if isempty(tmpline), tmpline = fgetl(fid); end;
                strs = strread(tmpline,'%s','delimiter',char(9))';
                if ~isempty(strs)
                    if isempty(strs{1}), strs(1) = []; end;
                    if isempty(strs{1}), strs(1) = []; end;
                end;
                suballchoices{count} = strs;
                
                if ~isempty(findstr('hz', lower(tmpline)))
                     allchoicesfull{count} = [ allchoices{count} ' by Hz increment' ];
                else allchoicesfull{count} = [ allchoices{count} ' by freq. bands' ];
                end;
                if ~isempty(findstr('hz', lower(tmpline)))
                     fprintf('Possible choice: "%s by Hz increment"\n', allchoices{count});
                else fprintf('Possible choice: "%s by freq. bands"\n' , allchoices{count});
                end;
                
                
                count = count+1;
            end;
            shownextline = 0;
        end;
        if isempty(tmpline)
            shownextline = 1;
        end;
    end;
    fclose(fid);
        