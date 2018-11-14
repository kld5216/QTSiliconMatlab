function open(handle)
%   open onstr if it's closed

if strcmp(handle.status,'closed')
    fopen(handle);
end
end