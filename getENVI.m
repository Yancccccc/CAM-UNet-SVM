function [data,row,col,n]= getENVI(filename_hdr,filename)
    % ������������ȡ.dat��.img��ʽ��ENVI����,���õ�������Ϊ.hdr��ʽ��ͷ�ļ���.dat��ʽ�������ļ�
    % ������ʾͼ�񣬲���ȡ������������������
    fid = fopen(filename_hdr,'r');    % 'r'���룬��w��д�� ���
    info = fread(fid, 'char=>char');  %����Ϊһ���ַ�
    info = info';  %��ͷ�ļ��е��ַ�ת��һ��
    fclose(fid);  %�ر��ļ�

    %ȷ������samples
    start = strfind(info,'samples = ');   %���ַ����ж�λ�ַ���,��֮ǰ��ȡ��info�в��ң���ʼ�ַ���Ϊsamples = ,��ֹ�ַ���Ϊlines��֮����ŵ����־���samples�Ĵ�С
    len = length('samples = ');   %��ȡ���ַ����ĳ���
    stop = strfind(info,'lines');    %��λ�ַ���λ��
    samples = [];

    for i = start+len : stop-1
        samples = [samples, info(i)];  %��ȡ�м���ַ�
    end
    samples = str2num(samples);  %�ַ���ת��Ϊ����
    row = samples;

    %ȷ������lines
    start = strfind(info,'lines   = ');
    len = length('lines   = ');
    stop = strfind(info,'bands');
    lines = [];
    for i = start+len : stop-1
        lines = [lines, info(i)];
    end
    lines = str2num(lines);
    col = lines;

    %��ȡ������
    start = strfind(info,'bands   = ');
    len = length('bands   = ');
    stop = strfind(info,'header offset ');
    bands = [];
    for i = start+len : stop-1
        bands = [bands, info(i)];
    end
    bands = str2num(bands);
    n = bands;

    % ��ȡ���ݸ�ʽ
    start = strfind(info,'data type = ');
    len = length('data type = ');
    stop = strfind(info,'interleave');
    datatype = [];
    for i = start+len : stop-1
        datatype = [datatype, info(i)];
    end
    datatype = str2num(datatype);

    %ȷ��datatypeȷ�������ݸ�ʽ
    precision = [];   % datatype��Ӧ�����ݸ�ʽ����
    switch datatype
        case 1
            precision = 'uint8 => uint8';
        case 2
            precision = 'int16 => int16';
        case 12
            precision = 'uint16 => uint16';
        case 3
            precision = 'int32 => int32';
        case 13
            precision = 'uint32 => uint32';
        case 4
            precision = 'float32 => float32';
        case 5
            precision = 'double => double';
        otherwise
            precision = 'invalid type';  %��Ч����
    end

    % ��ȡ�洢��ͼ������ݸ�ʽ
    start = strfind(info,'interleave = ');
    len = length('interleave = ');
    stop = strfind(info,'sensor type ');
    interleave = [];
    for i = start+len : stop-1
        interleave = [interleave, info(i)];
    end
    interleave = strtrim(interleave);

    %   byteorder : ���ݴ洢���ֽ����з�ʽ���С�ieee-le��(С��)����ieee-be��(���)
    %   �ನ�κ����Ķ�ȡ���� X = multibandread(filename, size, precision, offset, interleave, byteorder)
    %   data = multibandread('P1.dat',[lines,samples,bands],precision,0,interleave,'ieee-le',{'Row','Range',[1 500]},{'Column','Range',[1 500]});
   
    %�ж϶�ȡ�������ļ���ʲô���ͣ�dat
    if strfind(filename,'dat')~=0   
        data = multibandread(filename,[lines,samples,bands],precision,0,interleave,'ieee-le');
        figure (1);
        imshow(data);
   end
   
   if strfind(filename,'img')~=0
       data = multibandread(filename,[lines, samples, bands],precision,0,interleave,'ieee-le');
       figure (1);
       imshow(data);
%        % �����������ʾ
%        data1 = data(:,:,1);  % R
%        data2 = data(:,:,2);    % G
%        data3 = data(:,:,3);    % B
%        image = cat(3,data1,data2,data3);
%        figure (2);
%        imshow(image);  
   end
   
end

