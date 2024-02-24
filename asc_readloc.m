% asc_readloc() - Read channel location file
%
% Usage:
%   >> elec = asc_readloc( filename );
%
% Inputs:
%   filename   - [string] file name.
%   elec_names - [cell] names of electrode to read
%
% Outputs:
%  elec    - channel location structure
%
% 

function eloc = asc_readloc(filename, elec_names);

    % find electrode positions
    % ------------------------
    disp('Looking up channel locations...')
    template = asc_loadtxt(filename, 0, [9 32]);
    templatelabels = lower(template(:,2)');
    for index = 1:length(elec_names)
        tmpname = elec_names{index};
        minuspos = find(tmpname == '-');
        if ~isempty(minuspos), tmpname(minuspos:end) = []; end;
        eloc(index).labels = tmpname;
        if ~isnumeric(tmpname)
            elecpos = strmatch( lower(tmpname), templatelabels, 'exact');
            if ~isempty(elecpos)
                eloc(index).theta  = template{elecpos, 3};
                eloc(index).radius = template{elecpos, 4};
                eloc(index).X      = template{elecpos, 5};
                eloc(index).Y      = template{elecpos, 6};
                eloc(index).Z      = template{elecpos, 7};
            end;
        end;
    end;
    
    % make all electrode inside
    % -------------------------
    maxrad = max([ eloc.radius ]);
    for ind = 1:length(eloc)
        eloc(ind).radius = eloc(ind).radius/maxrad*0.5;
    end;
