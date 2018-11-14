function close(handle)
%   close handle if it's open

if strcmp(handle.status,'open')
    fclose(handle);
end
end
