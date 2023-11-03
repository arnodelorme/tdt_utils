% convert folder containing RObert's text file
% to a tdt file
function folder2tdt(foldname, outputname)

if nargin < 1
    disp('You need to provide a folder name');
end;

if nargin < 2
    outputname = foldname;
end;

% create the 3 output files
% -------------------------
fid1 = fopen(fullfile(foldname, [ outputname '_mean.txt']), 'w');
fid2 = fopen(fullfile(foldname, [ outputname '_sd.txt']), 'w');
fid3 = fopen(fullfile(foldname, [ outputname '_cv.txt']), 'w');

% title
% -----
fprintf(fid1, 'Mean for %s\n', foldname);
fprintf(fid2, 'Std-dev. for %s\n', foldname);
fprintf(fid3, 'Coef. var. for %s\n', foldname);

header = 0;
a = dir(foldname);
for index = 1:length(a)
    if length(a(index).name) > 2    
        if strcmpi(a(index).name(end-2:end), 'xls')
            elec = a(index).name(1:find(a(index).name == '_')-1);
            try,
            raw = loadtxt(fullfile(foldname, a(index).name), 'verbose', 'off');
            catch, disp(['Error loading' a(index).name ]); end;
            s   = raw(1,:); raw(1,:) = [];
            num = [ raw{:} ]; num = reshape(num, size(raw));
            m  = mean(num);
            sd = std(num);
            cv = sd./m;
            if header == 0
                header = 1;
                fprintf(fid1, '%s\t', s{:}); fprintf(fid1, '\n');
                fprintf(fid2, '%s\t', s{:}); fprintf(fid2, '\n');
                fprintf(fid3, '%s\t', s{:}); fprintf(fid3, '\n');
            end;
            fprintf(fid1, '%s\t', elec); fprintf(fid1, '%3.2f\t', m); fprintf(fid1, '\n');
            fprintf(fid2, '%s\t', elec); fprintf(fid2, '%3.2f\t', sd); fprintf(fid2, '\n');
            fprintf(fid3, '%s\t', elec); fprintf(fid3, '%3.2f\t', cv); fprintf(fid3, '\n');
        end;
    end;
end;
fclose(fid1);
fclose(fid2);
fclose(fid3);
