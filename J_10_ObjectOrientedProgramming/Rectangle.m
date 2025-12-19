classdef Rectangle
    properties (Access = protected)
        length
        width
    end

    methods
        function obj = Rectangle(length, width)
            obj.length = length;
            obj.width = width;
        end

        function perimeter = getPerimeter(obj)
            perimeter = 2*obj.length + 2*obj.width;
        end

        function area = getArea(obj)
            area = obj.length * obj.width;
        end
    end
end