function newFilename = get_unique_filename(filename)
    % Return the filename unchanged if it doesn't exist.
    if ~isfile(filename)
        newFilename = filename;
        return;
    end

    % Split filename into path, name, and extension.
    [folder, name, ext] = fileparts(filename);

    % Try _1, _2, _3, ...
    counter = 1;
    while true
        newFilename = fullfile(folder, sprintf('%s_%d%s', name, counter, ext));

        if ~isfile(newFilename)
            return;
        end

        counter = counter + 1;
    end
end