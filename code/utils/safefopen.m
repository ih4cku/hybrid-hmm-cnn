classdef safefopen < handle
% A wrapper class for file operation, automatic close file
% Constructor:
%   this = safeopen(f_name, arg)
%       f_name - file name
%       arg    - arguments
    properties(Access=public)
        fid;
        debug = false;
    end

    methods(Access=public)
        function this = safefopen(f_name, varargin)
            if nargin < 2
                varargin = {'r'};
            end
            [f, msg] = fopen(f_name, varargin{:});
            if f == -1
                throw(MException('safefopen:ErrorInIO', msg));
            end
            this.fid = f;
            
            if this.debug
                disp('-> file opened.');
            end
        end

        function fread(this, varargin)
            fread(this.fid, varargin{:});
        end
        
        function fwrite(this, varargin)
            fwrite(this.fid, varargin{:});
        end

        function ln = fgetl(this, varargin)
            ln = fgetl(this.fid, varargin{:});
        end

        function stat = feof(this, varargin)
            stat = feof(this.fid, varargin{:});
        end

        function fprintf(this, varargin)
            fprintf(this.fid, varargin{:});
        end
        
        function frewind(this, varargin)
            frewind(this.fid, varargin{:});
        end
        
        function c = textscan(this, varargin)
            c = textscan(this.fid, varargin{:});
        end

        function delete(this)
            errorId = fclose(this.fid);
            if errorId == -1
                msg = ferror(this.fid);
                throw(MException('safefopen:ErrorInIO', msg));
            end
            
            if this.debug
                disp('<- file closed.');
            end
        end
    end
end