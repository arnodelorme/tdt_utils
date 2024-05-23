% get tdt file properties
% -----------------------

% allchoices     - title choice
% suballchoices  - sub choice in Hz or freq. band
% allchoicesfull - same as allchoices with "by hz increment" or "by freq. band" text at the end

function [ fileinfo, allchoices, suballchoices, allchoicesfull ] = gettdtcontent(filename, choice, subchoice);

    % find title
    % ----------
    fields = { 'name' 'subject_id' 'dob' 'age' 'gender' 'handedness' 'eeg_id' ...
               'date' 'time' 'eyescondition' 'technician' 'doctor' 'clinician' 'medication' 'recordlen'  'editlen' 'epochlen' 'sampling_rate' 'collection_hardware' 'reliability' };	
    fieldtitle = { 'Name:' 'Subject ID:' 'Date of Birth:' 'Age:' 'Gender:' ...
        'Handedness:' 'EEG ID:' 'Date of Test:'	'Time of Test:'	'Eyes Condition:' 'Technician:' ...
        'Doctor:' 'Clinician:' 'Medication:'	'Record Length:' 'Edit Length:' 'Epoch Length (sec):' 'Sampling Rate:' 'Collection Hardware:' 'Reliability:' };
    fileinfo = [];
    fileinfo.epochlen = '1';
    fid = fopen(filename, 'r');
    if fid == -1, error(['Cannot open file ' filename]); end
    while ~feof(fid)
        tmpline = fgetl(fid);
        if ~isempty(tmpline)
            for iField = 1:length(fieldtitle)
                ind = findstr(fieldtitle{iField}, tmpline);
                if ~isempty(ind), break; end
            end
            if isempty(ind)
                fseek(fid, -1, 0); % one character back
                break;
            else
                if ~isempty(findstr('Reliability:', tmpline))
                    % multi line special case
                    str = tmpline;
                    tmpline = 'xxx';
                    while ~isempty(tmpline)
                        tmpline = fgetl(fid);
                        str = strvcat(str, tmpline);
                    end
                    fileinfo = setfield( fileinfo, fields{iField}, str);
                else
                    fileinfo = setfield( fileinfo, fields{iField}, tmpline(length(fieldtitle{iField})+1:end));
                end
            end
        end
    end
    fileinfo.epochlen = num2str(fileinfo.epochlen);
    
    % check readability

    % search for strings
    % ------------------
    shownextline = 1;
    count        = 1;
    while ~feof(fid)
        if count > 1
            tmpline = fgetl(fid); % read one line
        end
        if shownextline && ~isempty(tmpline)
            if tmpline(1) ~= 9 && ~contains(tmpline, 'TBI')
                allchoices{count} = tmpline;
                tmpline = fgetl(fid);
                if isempty(tmpline), tmpline = fgetl(fid); end
                strs = strread(tmpline,'%s','delimiter',char(9))';
                if ~isempty(strs)
                    if isempty(strs{1}), strs(1) = []; end
                    if isempty(strs{1}), strs(1) = []; end
                end
                suballchoices{count} = strs;
                
                if ~isempty(findstr('hz', lower(tmpline)))
                    allchoicesfull{count} = [ allchoices{count} ' by Hz increment' ];
                    fprintf('Possible choice: "%s by Hz increment"\n', allchoices{count});
                else
                    if ~contains(allchoices{count}, 'Traumatic Brain Injury')
                        allchoicesfull{count} = [ allchoices{count} ' by freq. bands' ];
                        fprintf('Possible choice: "%s by freq. bands"\n' , allchoices{count});
                    else
                        fprintf('Possible choice: "%s"\n' , allchoices{count});
                    end
                end
                
                count = count+1;
            end
            shownextline = 0;
        end
        if isempty(tmpline)
            shownextline = 1;
        end
    end
    fclose(fid);
        