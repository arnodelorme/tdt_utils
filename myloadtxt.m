% load text file
% --------------
function alldat= myloadtxt(fid, delim)

    r = 1;
    args = fgetl(fid);
    while(~isempty(args))
        
        c = 1;
        while ~isempty(args)
             [tmp, args] = strtok(args, delim);
             tmp2 = str2num(tmp);
             if isempty( tmp2 )  , alldat{r,c} = tmp;
             else                  alldat{r,c} = tmp2;
             end
             c = c+1;
        end
        r = r+1;
        args = fgetl(fid);
    end
    

    