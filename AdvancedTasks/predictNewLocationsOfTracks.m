%%
    function predictNewLocationsOfTracks(tracks)
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;
            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);          
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end