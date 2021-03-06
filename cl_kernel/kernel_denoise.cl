/*
 * function: kernel_denoise
 *     bi-laterial filter for denoise usage
 * input:    image2d_t as read only
 * output:   image2d_t as write only
 * sigma_r:  the parameter to set sigma_r in the Gaussian filtering
 * imw:      image width, used for edge detect
 * imh:      image height, used for edge detect
 */


__kernel void kernel_denoise(__read_only image2d_t srcRGB, __write_only image2d_t dstRGB, float sigma_r, unsigned int imw, unsigned int imh)
{
    int x = 4 * get_global_id(1);
    int y = get_global_id(0);
    float normF;
    float normF1;
    float normF2;
    float normF3;
    float H;
    float delta;
    int i = 0;
    sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_NONE | CLK_FILTER_NEAREST;
    sigma_r = 2 * pown(sigma_r, 2);

    float4 line, line1;
    float4 line2, line3;
    float4 line4, line5;
    float4 line6, line7;
    float4 tmp[2];

    line = read_imagef(srcRGB, sampler, (int2)(x, y));
    line2 = read_imagef(srcRGB, sampler, (int2)(x + 1, y));
    line4 = read_imagef(srcRGB, sampler, (int2)(x + 2, y));
    line6 = read_imagef(srcRGB, sampler, (int2)(x + 3, y));

    if (x > 2 &&
            x < (imw - 6) &&
            y > 2 &&
            y < (imh - 3))
    {

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x - 2, y - 2));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line1.x = tmp[0].x * H;
        line1.y = tmp[0].y * H;
        line1.z = tmp[0].z * H;
        normF = H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x - 2, y - 1));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x - 2, y));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8077;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x - 2, y + 1));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x - 2, y + 2));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;


        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x - 1, y - 2));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line3.x = tmp[1].x * H;
        line3.y = tmp[1].y * H;
        line3.z = tmp[1].z * H;
        normF1 = H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x - 1, y - 1));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x - 1, y));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;


        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x - 1, y + 1));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x - 1, y + 2));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;


        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x, y - 2));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line5.x = tmp[0].x * H;
        line5.y = tmp[0].y * H;
        line5.z = tmp[0].z * H;
        normF2 = H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x, y - 1));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.94595945;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;

        line1.x += line.x;
        line1.y += line.y;
        line1.z += line.z;
        normF += 1;
        delta = pown(line.x - line2.x, 2) + pown(line.y - line2.y, 2) + pown(line.z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line3.x += line.x * H;
        line3.y += line.y * H;
        line3.z += line.z * H;
        normF1 += H;
        delta = pown(line.x - line4.x, 2) + pown(line.y - line4.y, 2) + pown(line.z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line5.x += line.x * H;
        line5.y += line.y * H;
        line5.z += line.z * H;
        normF2 += H;


        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x, y + 1));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.94595945;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x, y + 2));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;


        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 1, y - 2));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 1, y - 1));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;


        delta = pown(line2.x - line.x, 2) + pown(line2.y - line.y, 2) + pown(line2.z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        line3.x += line2.x;
        line3.y += line2.y;
        line3.z += line2.z;
        normF1 += 1;
        delta = pown(line2.x - line4.x, 2) + pown(line2.y - line4.y, 2) + pown(line2.z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(line2.x - line6.x, 2) + pown(line2.y - line6.y, 2) + pown(line2.z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 1, y + 1));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.94595945;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 1, y + 2));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;


        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 2, y - 2));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 2, y - 1));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.94595945;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        delta = pown(line4.x - line.x, 2) + pown(line4.y - line.y, 2) + pown(line4.z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line1.x += line4.x * H;
        line1.y += line4.y * H;
        line1.z += line4.z * H;
        normF += H;
        delta = pown(line4.x - line2.x, 2) + pown(line4.y - line2.y, 2) + pown(line4.z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line3.x += line4.x * H;
        line3.y += line4.y * H;
        line3.z += line4.z * H;
        normF1 += H;
        line5.x += line4.x;
        line5.y += line4.y;
        line5.z += line4.z;
        normF2 += 1;
        delta = pown(line4.x - line6.x, 2) + pown(line4.y - line6.y, 2) + pown(line4.z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line7.x += line4.x * H;
        line7.y += line4.y * H;
        line7.z += line4.z * H;
        normF3 += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 2, y + 1));
        delta = pown(tmp[0].x - line.x, 2) + pown(tmp[0].y - line.y, 2) + pown(tmp[0].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line1.x += tmp[0].x * H;
        line1.y += tmp[0].y * H;
        line1.z += tmp[0].z * H;
        normF += H;
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.94595945;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 2, y + 2));
        delta = pown(tmp[1].x - line.x, 2) + pown(tmp[1].y - line.y, 2) + pown(tmp[1].z - line.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line1.x += tmp[1].x * H;
        line1.y += tmp[1].y * H;
        line1.z += tmp[1].z * H;
        normF += H;
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        line.x = line1.x / normF;
        line.y = line1.y / normF;
        line.z = line1.z / normF;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 3, y - 2));
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7454;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 3, y - 1));
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.94595945;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        delta = pown(line6.x - line2.x, 2) + pown(line6.y - line2.y, 2) + pown(line6.z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line3.x += line6.x * H;
        line3.y += line6.y * H;
        line3.z += line6.z * H;
        normF1 += H;
        delta = pown(line6.x - line4.x, 2) + pown(line6.y - line4.y, 2) + pown(line6.z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line5.x += line6.x * H;
        line5.y += line6.y * H;
        line5.z += line6.z * H;
        normF2 += H;
        line7.x += line6.x;
        line7.y += line6.y;
        line7.z += line6.z;
        normF3 += 1;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 3, y + 1));
        delta = pown(tmp[1].x - line2.x, 2) + pown(tmp[1].y - line2.y, 2) + pown(tmp[1].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line3.x += tmp[1].x * H;
        line3.y += tmp[1].y * H;
        line3.z += tmp[1].z * H;
        normF1 += H;
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.94595945;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 3, y + 2));
        delta = pown(tmp[0].x - line2.x, 2) + pown(tmp[0].y - line2.y, 2) + pown(tmp[0].z - line2.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line3.x += tmp[0].x * H;
        line3.y += tmp[0].y * H;
        line3.z += tmp[0].z * H;
        normF1 += H;
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        line2.x = line3.x / normF1;
        line2.y = line3.y / normF1;
        line2.z = line3.z / normF1;


        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 4, y - 2));
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7454;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;


        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 4, y - 1));
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 4, y  ));
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.9459;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 4, y + 1));
        delta = pown(tmp[0].x - line4.x, 2) + pown(tmp[0].y - line4.y, 2) + pown(tmp[0].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line5.x += tmp[0].x * H;
        line5.y += tmp[0].y * H;
        line5.z += tmp[0].z * H;
        normF2 += H;
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8948;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 4, y + 2));
        delta = pown(tmp[1].x - line4.x, 2) + pown(tmp[1].y - line4.y, 2) + pown(tmp[1].z - line4.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line5.x += tmp[1].x * H;
        line5.y += tmp[1].y * H;
        line5.z += tmp[1].z * H;
        normF2 += H;
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        line4.x = line5.x / normF2;
        line4.y = line5.y / normF2;
        line4.z = line5.z / normF2;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 5, y - 2));
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 5, y - 1));
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 5, y  ));
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.8007;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        tmp[1] = read_imagef(srcRGB, sampler, (int2)(x + 5, y + 1));
        delta = pown(tmp[1].x - line6.x, 2) + pown(tmp[1].y - line6.y, 2) + pown(tmp[1].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.7574;
        line7.x += tmp[1].x * H;
        line7.y += tmp[1].y * H;
        line7.z += tmp[1].z * H;
        normF3 += H;

        tmp[0] = read_imagef(srcRGB, sampler, (int2)(x + 5, y + 2));
        delta = pown(tmp[0].x - line6.x, 2) + pown(tmp[0].y - line6.y, 2) + pown(tmp[0].z - line6.z, 2);
        H = exp(-delta / sigma_r) * 0.6411;
        line7.x += tmp[0].x * H;
        line7.y += tmp[0].y * H;
        line7.z += tmp[0].z * H;
        normF3 += H;

        line6.x = line7.x / normF3;
        line6.y = line7.y / normF3;
        line6.z = line7.z / normF3;
    }
    write_imagef(dstRGB, (int2)(x, y), line);
    write_imagef(dstRGB, (int2)(x + 1, y), line2);
    write_imagef(dstRGB, (int2)(x + 2, y), line4);
    write_imagef(dstRGB, (int2)(x + 3, y), line6);
}
