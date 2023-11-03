function [arcx, arcy] = plotarc(a,b,c, varargin);

pnts = 50;

ax = a(1); ay = a(2);
bx = b(1); by = b(2);
cx = c(1); cy = c(2);
mat = [2*bx-2*ax   2*by-2*ay;
       2*cx-2*ax   2*cy-2*ay ];
res = [-ax^2+bx^2-ay^2+by^2;
       -ax^2+cx^2-ay^2+cy^2 ];
if abs((ax+bx)/2-cx) < 0.001 & abs((ay+by)/2-cy) < 0.001
    arcx = linspace(ax, bx, pnts); arcx = [ arcx(1:end-1)' arcx(2:end)' ];
    arcy = linspace(ay, by, pnts); arcy = [ arcy(1:end-1)' arcy(2:end)' ];
else   
    D = mat\res; 
    dx = D(1); dy = D(2);
    r = sqrt( (cx-dx)^2 + (cy-dy)^2 );

    ang_a = atan2((ay-dy)/r, (ax-dx)/r); ang_a = ang_a+4*pi;
    ang_b = atan2((by-dy)/r, (bx-dx)/r); ang_b = ang_b+4*pi;

    if abs(ang_a-ang_b) > pi, 
        if abs(ang_a-2*pi-ang_b) > pi,  ang_b = ang_b - 2*pi; 
        else                            ang_a = ang_a - 2*pi; 
        end;
    end;
    if ang_a < ang_b, if ang_b-ang_a>2*pi, ang_a=ang_a+2*pi; end; allangles = linspace(ang_a, ang_b, pnts);
    else              if ang_a-ang_b>2*pi, ang_b=ang_b+2*pi; end; allangles = linspace(ang_b, ang_a, pnts);
    end;

    % get arc
    radius = sqrt( (cx-dx)^2 + (cy-dy)^2 );
    count = 1;
    for i = 2:length(allangles)
        arcx(count,:) = [ cos(allangles(i-1))*r cos(allangles(i))*r ]+dx;
        arcy(count,:) = [ sin(allangles(i-1))*r sin(allangles(i))*r ]+dy;
        count = count+1;
    end;
end;

if nargin > 3
    hold on;
    %plot(ax, ay, 'r.'); 
    %plot(bx, by, 'r.');
    %plot(cx, cy, 'r.');
    %plot(dx, dy, 'r.');
    line(arcx,arcy, varargin{:});
end;