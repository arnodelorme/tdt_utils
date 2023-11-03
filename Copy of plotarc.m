function [arcx, arcy] = plotarc(a,b,c, tmp);

xa = a(1); ya = a(2);
xb = b(1); yb = b(2);
xc = c(1); yc = c(2);
mat = [2*xb-2*xa   2*yb-2*ya;
       2*xc-2*xa   2*yc-2*ya ];
res = [-xa^2+xb^2-ya^2+yb^2;
       -xa^2+xc^2-ya^2+yc^2 ];
D = mat\res; 
xd = D(1); yd = D(2);
r = sqrt( (xc-xd)^2 + (yc-yd)^2 );

ang_a = atan2((ya-yd)/r, (xa-xd)/r); ang_a = ang_a+4*pi;
ang_b = atan2((yb-yd)/r, (xb-xd)/r); ang_b = ang_b+4*pi;

if abs(ang_a-ang_b) > pi
    ang_a = ang_a - 2*pi;
end;
if ang_a < ang_b, allangles = linspace(ang_a, ang_b, round((ang_b-ang_a)/pi*180));
else              allangles = linspace(ang_b, ang_a, round((ang_a-ang_b)/pi*180));
end;

% get arc
radius = sqrt( (xc-xd)^2 + (yc-yd)^2 );
count = 1;
for i = 2:length(allangles)
    arcx(count,:) = [ cos(allangles(i-1))*r; cos(allangles(i))*r ]+xd;
    arcy(count,:) = [ sin(allangles(i-1))*r; sin(allangles(i))*r ]+yd;
    count = count+1;
end;

if nargin > 3
    hold on;
    plot(xa, ya, 'r.'); 
    plot(xb, yb, 'r.');
    plot(xc, yc, 'r.');
    plot(xd, yd, 'r.');
    line(arcx,arcy);
end;