function mindist = elec_dist_to_arc( arcx, arcy, elecx, elecy);

alldist = zeros(length(arcx), length(elecx));

arcx = repmat(arcx(:), [1 length(elecx)]);
arcy = repmat(arcy(:), [1 length(elecy)]);
elecx = repmat(elecx(:)', [size(arcx,1) 1]);
elecy = repmat(elecy(:)', [size(arcy,1) 1]);

alldist = sqrt((arcx-elecx).^2+(arcy-elecy).^2);
mindist = min(min(alldist));