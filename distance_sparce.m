function [distancetoshore] = distance_sparce(tracklat, tracklon)

coastline = shaperead('Coastline2021.shp');

lonedges = [min(tracklon)-.1 max(tracklon)+.1];

tempcoast_lat = coastline(1).Y(coastline(1).X> lonedges(1) &...
    coastline(1).X< lonedges(2));

tempcoast_lat_dense = interp1(tempcoast_lat, (1:length(tempcoast_lat)*20)/20, 'linear');

tempcoast_lon = coastline(1).X(coastline(1).X> lonedges(1) &...
    coastline(1).X< lonedges(2));

tempcoast_lon_dense = interp1(tempcoast_lon, (1:length(tempcoast_lon)*20)/20, 'linear');


subset_tracklat = find(tracklat > min(tempcoast_lat) & tracklat < max(tempcoast_lat)+1);

distancetoshore = nan(1, numel(tracklat));


for n = 1:500:length(tracklat) % changed this from 1000 to 500 for pretty figures 

    if ismember(n, subset_tracklat)
        dist2shore = nan(1, numel(tempcoast_lat_dense));
        
      %  for m = 1:length(tempcoast_lat_dense)
                %[d1, d2] = lldistkm([tracklat(n), tracklon(n)], [tempcoast_lat_dense(m), tempcoast_lon_dense(m)]);
                dist2shore = distance(tracklat(n), tracklon(n), tempcoast_lat_dense, tempcoast_lon_dense,wgs84Ellipsoid("km") );
               % (m) = d1;%  3.29e-05*d1^3 - 0.004787*d1^2 + 1.219*d1 - 0.3317;
 %       end
    
        distancetoshore(n) = min(dist2shore);
    end


end

[err, index] = min(distancetoshore);

for n = max(index-1000, 1):min(index+1000, length(tracklat))
    dist2shore = nan(1, numel(tempcoast_lat_dense));
    
  %  for m = 1:length(tempcoast_lat_dense)
            %[d1, d2] =lldistkm([tracklat(n), tracklon(n)], [tempcoast_lat_dense(m), tempcoast_lon_dense(m)]);
            dist2shore = distance(tracklat(n), tracklon(n), tempcoast_lat_dense, tempcoast_lon_dense, wgs84Ellipsoid("km"));
        %    (m) = d1;%3.29e-05*d1^3 - 0.004787*d1^2 + 1.219*d1 - 0.3317;
 %   end

    distancetoshore(n) = min(dist2shore);

end

%% fill in the zeros in the sparce calculation

distancetoshore = fillmissing(distancetoshore, 'linear');

%% correct the south-of-shore to be negative

if tracklat(2) - tracklat(1) > 0

    [~, crossing] = min(distancetoshore);
    offset = distancetoshore(crossing);
    distancetoshore(1:crossing) = -distancetoshore(1:crossing)-offset;
else
    [~, crossing] = min(distancetoshore);
    offset = distancetoshore(crossing);
    distancetoshore(crossing:end) = -distancetoshore(crossing:end)-offset;
end



end
