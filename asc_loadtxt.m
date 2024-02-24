% asc_loadtxt() - load ascii file.
%
% Usage:
% >> data = asc_loadtxt(filein, headerlines, delim);
%
% Input:
%   filein      - [string] input file in ASCII format.
%   headerlines - [integer] number of lines in header
%   delim       - [array of char] char delimiter
%
% Output:
%   data    - [real] data array
%
% 

function alldat = asc_loadtxt(filename, skip, delim);

    fid = fopen(filename, 'r');
    % skip lines ---------
    index = 0;
    while index < abs(skip)
        tmpline = fgetl(fid); 
        if skip > 0 | ~isempty(tmpline)
            index = index + 1;
        end;    
    end; 
    
    % read file
    % ---------
    r = 1;
    while(~feof(fid))
        
        args = fgetl(fid);
        if isempty(args), args = fgetl(fid); end;
        c = 1;
        while ~isempty(args)
             [tmp args] = strtok(args, delim);
             if ~isempty(tmp) & tmp(1) > 43 & tmp(1) < 59, tmp2 = str2num(tmp);
             else tmp2 = []; end;
             if isempty( tmp2 )  , alldat{r,c} = tmp;
             else                  alldat{r,c} = tmp2;
             end;
             c = c+1;
        end;
        r = r+1;
    end;
    
    fclose(fid);
    