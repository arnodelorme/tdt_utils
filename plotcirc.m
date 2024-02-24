theta = 10;
xa = cos(theta/180*pi);    ya = sin(theta/180*pi);
xb = cos(theta/180*pi+pi); yb = sin(theta/180*pi+pi);
[x y] = plotortho([xa ya],[xb yb]);
xc = x(3);
yc = y(3);
plotarc([xa ya], [xb yb], [xc yc]);
return;

mat = [2*xb-2*xa   2*yb-2*ya;
       2*xc-2*xa   2*yc-2*ya];
res = [-xa^2+xb^2-ya^2+yb^2;
       -xa^2+xc^2-ya^2+yc^2 ];
D = mat\res; xd = D(1); yd = D(2);

hold on;
plot(xa, ya, 'r.'); 
plot(xb, yb, 'r.');
plot(xc, yc, 'r.');
plot(xd, yd, 'r.');

radius = sqrt( (xc-xd)^2 + (yc-yd)^2 );
count = 1;
for theta = 0:10:350
    a(count,:) = [ cos((theta-10)/180*pi)*radius; cos(theta/180*pi)*radius ]+xd;
    b(count,:) = [ sin((theta-10)/180*pi)*radius; sin(theta/180*pi)*radius ]+yd;
    count = count+1;
end;
line(a,b);