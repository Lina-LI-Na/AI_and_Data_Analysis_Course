classdef Parallelogram<Rectangle
    %UNTITLED4 此处显示有关此类的摘要
    %   此处显示详细说明

    properties 
        angle
    end

    methods
        function obj = Parallelogram(length, width, angle)
            obj = obj@Rectangle(length, width)
            obj.angle = angle;
        end

        function area = getArea(obj)
            area = obj.length * obj.width * sind(obj.angle);
        end
    end
end