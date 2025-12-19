classdef CollegeStudent<Student
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明

    properties
        major
    end

    methods
        function obj = CollegeStudent(name, school, major)
            obj = obj@Student(name, school)
            obj.major = major;
        end

        function info(obj)
            info@Student(obj);
            disp("Major: " + obj.major);
        end

        function level = getScoreLevel(~,score)
            if score >= 90
                level = "A";
            elseif score >= 80
                level = "B";
            elseif score >= 70
                level = "C";
            elseif score >= 60
                level = "D";
            else
                level = "F";
            end
        end
    end
end