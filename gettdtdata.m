% search for title line in file
% the file is then positioned 
% -----------------------------
function [alldat, allstd, elec, subchoice, filetmp] = gettdtdata(filename, choice, subchoice)

    if nargin < 2
        return;
    end
    if nargin < 3
        subchoice = [];
    end

    if ~iscell(subchoice), subchoice = { subchoice }; end
    fid = fopen(filename, 'r');
    if fid == -1, error(['Cannot open file ' filename]); end
    
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
                filechoice = tmpline;
                tmpline = fgetl(fid);
                if isempty(tmpline), tmpline = fgetl(fid); end
                strs = strread(tmpline,'%s','delimiter',char(9))';
                if ~isempty(strs)
                    if isempty(strs{1}), strs(1) = []; end
                    if isempty(strs{1}), strs(1) = []; end
                end
                subfilechoice = strs;
                
                % get the actual data
                % -------------------
                if strcmpi(choice, filechoice)
                    if ~isempty(subchoice{1})
                        
                        % the line below allows to choose Hz versus Bands
                        % if the result is empty then the test afterward
                        % allows to continue the search
                        [tmp, inds] = intersect(subfilechoice, subchoice);
                        inds = sort(inds);
                        
                        if length(inds) == length(subchoice)
                            alldat = myloadtxt(fid , 9);
                            fclose(fid);
                            
                            % get title line
                            if isstr(alldat{1,3})
                                titles = alldat(1,:);
                                alldat(1,:) = [];
                                if isempty(titles{1}), titles(1) = []; end
                                if isempty(titles{1}), titles(1) = []; end
                                for ind = 1:length(subchoice)
                                    subchoice{ind} = [ subchoice{ind} ' (' titles{inds(ind)} ')' ];
                                end
                            else
                                titles = [];
                            end
                            
                            % get electrodes
                            if isstr(alldat{2,2})
                                elec   = alldat(:,1:2);
                                alldat(:,1:2) = [];
                            else
                                elec   = alldat(:,1);
                                alldat(:,1) = [];
                            end
                            
                            % get standard deviation
                            if size(alldat,2) > length(subfilechoice)
                                allstd = alldat(:,inds+length(subfilechoice));
                            else
                                allstd = [];
                            end
                            alldat = alldat(:,inds);

                            if isempty(alldat{1}) 
                                alldat(1) = [];
                                allstd(1) = [];
                                elec(1) = [];
                            end
                            return;
                        elseif length(inds) > 1
                            error('Wrong band name');
                        end
                    end
                end
                
            end
            shownextline = 0;
        end
        if isempty(tmpline)
            shownextline = 1;
        end
    end
    fclose(fid);
