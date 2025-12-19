classdef Clock < handle
    %UNTITLED5 此处显示有关此类的摘要
    %   此处显示详细说明

    properties
        time = datetime("now");
    end

    events
        TimeChange
    end

    methods
        function change(obj, t)
            if (obj.time ~= t)
                obj.time = t;
                notify(obj, 'TimeChange')
            end

        end

        function showTime(obj, src, data)
            %obj.time = datetime("now");
            disp(['时间：' + string(obj.time)])
        end
    end
end