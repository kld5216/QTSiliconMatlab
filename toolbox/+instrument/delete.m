function delete(handle)
%   delete handle

if strcmp(handle.status,'open')
    fclose(handle);
end
delete(handle);
end