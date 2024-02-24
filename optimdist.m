%function dist = optimdist( index, a, b, cs, elecx, elecy);

[chans] = asc_readheader('chanorder1.txt');
eloc    = asc_readloc('chanlocs10-5.ced', chans);
th = [ eloc.theta ];
rd = [ eloc.radius ];
[y x] = pol2cart(th/180*pi, rd); x=-x;

figure;
plot(x, y, '.'); axis equal; axis off;

i = 17;
j = 7;
for i=1 %1:length(x)
    %for j=(i+1):length(x)
    for j= [1:i-1, i+1:length(x)]
        ax = x(i); ay = y(i);
        bx = x(j); by = y(j);
        elecx = [x(1:min(i,j)-1) x(min(i,j)+1:max(i,j)-1) x(max(i,j)+1:end) ];
        elecy = [y(1:min(i,j)-1) y(min(i,j)+1:max(i,j)-1) y(max(i,j)+1:end) ];
        %val = fminsearch(@disterror, 0, [], ax, ay, bx, by, elecx, elecy);
        if disterror(0, ax, ay, bx, by, elecx, elecy) > 0.95
             val = fminbnd(@disterror, -0.1, 0.1, [], ax, ay, bx, by, elecx, elecy);
        else val = 0;
        end;
        array(i,j) = val;
        [cx cy] = plotortho([ax ay],[bx by], val);
        [arcx arcy] = plotarc([ax ay], [bx by], [cx cy], 'color', 'r');
    end;
    disp(i);
end;

% write file
% ----------
fid =fopen('curvature.txt', 'w');
for i=1:length(chans)
    fprintf(fid, '%s\t', chans{i});
end;
fprintf(fid, '\n');
for i=1:length(x)
    for j=1:length(x)
        fprintf(fid, '%f\t', array(i,j));
    end;
    fprintf(fid, '\n');
end;    
fclose(fid);
