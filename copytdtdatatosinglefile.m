% search for title line in file
% the file is then positioned 
% -----------------------------
function [fileout] = copytdtdatatosinglefile(filename, choice, subchoice, fileout)

    if nargin < 2
        return;
    end
    if nargin < 3
        subchoice = [];
    end
    if nargin < 4
        fileout = 'temp.tdt';
    end

    if ~iscell(subchoice), subchoice = { subchoice }; end
    fid = fopen(filename, 'r');
    if fid == -1, error(['Cannot open file ' filename]); end

    fod = fopen(fileout, 'w');
    if fod == -1, error('Cannot write temporary file in current folder'); end;
    fprintf(fod, '\n%s\n\n\t', choice);
    for iChoice = 1:length(subchoice)
        fprintf(fod, '\t%s', subchoice{iChoice}); % line of text
    end
    fprintf(fod, '\n');

    % search for strings
    % ------------------
    shownextline = 0;
    nblines      = 0;
    count        = 1;
    r            = 1;
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

                            args = fgetl(fid);
                            args = fgetl(fid);
                            while ~isempty(args)

                                c = 1;
                                while ~isempty(args)
                                    [tmp, args] = strtok(args, 9);
                                    tmp2 = str2num(tmp);
                                    if isempty( tmp2 )  , alldat{r,c} = tmp;
                                    else                  alldat{r,c} = tmp2;
                                    end
                                    if ismember(c, [1 2 2+inds(:)'])
                                        fprintf(fod, '%s\t', tmp);
                                        % if ~(c ==1 && r == 1)
                                        %     fprintf(fod, '%s\t', tmp);
                                        % else
                                        %     fprintf(fod, '\t\t');
                                        % end
                                    end
                                    c = c+1;
                                end
                                fprintf(fod, '\n');
                                r = r+1;
                                args = fgetl(fid);
                            end
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
    fprintf(fod, '\n');


