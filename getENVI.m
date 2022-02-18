function [data,row,col,n]= getENVI(filename_hdr,filename)
    % 本函数用来读取.dat与.img格式的ENVI数据,所用到的数据为.hdr格式的头文件与.dat格式的数据文件
    % 可以显示图像，并读取行数、列数、波段数
    fid = fopen(filename_hdr,'r');    % 'r'读入，‘w’写出 句柄
    info = fread(fid, 'char=>char');  %读入为一列字符
    info = info';  %将头文件中的字符转成一行
    fclose(fid);  %关闭文件

    %确定行数samples
    start = strfind(info,'samples = ');   %在字符串中定位字符串,从之前读取的info中查找，开始字符串为samples = ,终止字符串为lines，之间夹着的数字就是samples的大小
    len = length('samples = ');   %读取该字符串的长度
    stop = strfind(info,'lines');    %定位字符串位置
    samples = [];

    for i = start+len : stop-1
        samples = [samples, info(i)];  %读取中间的字符
    end
    samples = str2num(samples);  %字符串转化为数字
    row = samples;

    %确定列数lines
    start = strfind(info,'lines   = ');
    len = length('lines   = ');
    stop = strfind(info,'bands');
    lines = [];
    for i = start+len : stop-1
        lines = [lines, info(i)];
    end
    lines = str2num(lines);
    col = lines;

    %获取波段数
    start = strfind(info,'bands   = ');
    len = length('bands   = ');
    stop = strfind(info,'header offset ');
    bands = [];
    for i = start+len : stop-1
        bands = [bands, info(i)];
    end
    bands = str2num(bands);
    n = bands;

    % 读取数据格式
    start = strfind(info,'data type = ');
    len = length('data type = ');
    stop = strfind(info,'interleave');
    datatype = [];
    for i = start+len : stop-1
        datatype = [datatype, info(i)];
    end
    datatype = str2num(datatype);

    %确定datatype确定的数据格式
    precision = [];   % datatype对应的数据格式，是
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
            precision = 'invalid type';  %无效类型
    end

    % 获取存储的图像的数据格式
    start = strfind(info,'interleave = ');
    len = length('interleave = ');
    stop = strfind(info,'sensor type ');
    interleave = [];
    for i = start+len : stop-1
        interleave = [interleave, info(i)];
    end
    interleave = strtrim(interleave);

    %   byteorder : 数据存储的字节排列方式，有’ieee-le’(小端)，‘ieee-be’(大端)
    %   多波段函数的读取规则： X = multibandread(filename, size, precision, offset, interleave, byteorder)
    %   data = multibandread('P1.dat',[lines,samples,bands],precision,0,interleave,'ieee-le',{'Row','Range',[1 500]},{'Column','Range',[1 500]});
   
    %判断读取的数据文件是什么类型，dat
    if strfind(filename,'dat')~=0   
        data = multibandread(filename,[lines,samples,bands],precision,0,interleave,'ieee-le');
        figure (1);
        imshow(data);
   end
   
   if strfind(filename,'img')~=0
       data = multibandread(filename,[lines, samples, bands],precision,0,interleave,'ieee-le');
       figure (1);
       imshow(data);
%        % 三波段组合显示
%        data1 = data(:,:,1);  % R
%        data2 = data(:,:,2);    % G
%        data3 = data(:,:,3);    % B
%        image = cat(3,data1,data2,data3);
%        figure (2);
%        imshow(image);  
   end
   
end

