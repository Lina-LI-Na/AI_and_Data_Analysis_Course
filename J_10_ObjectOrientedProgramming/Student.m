classdef Student
    % 表示学生的类

    properties
        name = "Jack";
        %school = "Suzhou No.1 Primary School";
    end

    properties (Access = protected)
        school = "Suzhou No.1 Primary School";
    end            

    methods
        function obj = Student(name, school)
            obj.name = name;
            obj.school = school;
        end

        function info(obj)
            disp("Name: " + obj.name);
            disp("School: " + obj.school);
        end

        function level = getScoreLevel(~,score)
            if score >= 85
                level = "Excellent";
            elseif score >= 75
                level = "Good";
            elseif score >= 60
                level = "Pass";
            else
                level = "Failed";
            end
         end
    end
end