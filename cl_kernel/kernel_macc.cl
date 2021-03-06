/*
 * function: kernel_macc
 * input:    image2d_t as read only
 * output:   image2d_t as write only
 * table: macc table.
 */
unsigned int get_sector_id (float u, float v)
{
    if ((u >= 0.0) && (v >= 0.0 ))
    {
        if (v / u <= 0.5)
            return 0;
        else if ((v / u > .05) && (v / u <= 1.0))
            return 1;
        else if ((v / u > 1.0) && (v / u <= 2.0))
            return 2;
        else
            return 3;
    }
    else if ((u < 0.0) && (v >= 0.0))
    {
        if (v / u <= -2.0)
            return 4;
        if ((v / u > -2.0) && (v / u <= -1.0))
            return 5;
        if ((v / u > -1.0) && (v / u <= -0.5))
            return 6;
        else
            return 7;
    }
    else if ((u < 0.0) && (v <= 0.0))
    {
        if (v / u <= 0.5)
            return 8;
        else if ((v / u > 0.5) && (v / u <= 1.0))
            return 9;
        else if ((v / u > 1.0) && (v / u <= 2.0))
            return 10;
        else
            return 11;
    }
    else
    {
        if(v / u <= -2.0)
            return 12;
        else if((v / u > -2.0) && (v / u <= -1.0))
            return 13;
        else if((v / u > -1.0) && (v / u <= -0.5))
            return 14;
        else
            return 15;
    }
}
__kernel void kernel_macc (__read_only image2d_t input, __write_only image2d_t output, __global float *table)
{
    int x = get_global_id (0);
    int y = get_global_id (1);
    sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_NONE | CLK_FILTER_NEAREST;
    int2 pos = (int2)(x, y);
    float4 pixel_in, pixel_out;
    pixel_in = read_imagef(input, sampler, pos);
    float Y, ui, vi, uo, vo;
    unsigned int table_id;
    Y = 0.3 * pixel_in.x + 0.59 * pixel_in.y + 0.11 * pixel_in.z;
    ui = 0.493 * (pixel_in.z - Y);
    vi = 0.877 * (pixel_in.x - Y);
    table_id = get_sector_id(ui, vi);
    uo = ui * table[4 * table_id] + vi * table[4 * table_id + 1];
    vo = ui * table[4 * table_id + 2] + vi * table[4 * table_id + 3];
    pixel_out.x = Y + 1.14 * vo;
    pixel_out.y = Y - 0.39 * uo - 0.58 * vo;
    pixel_out.z = Y + 2.03 * uo;
    pixel_out.w = 0.0;
    write_imagef(output, pos, pixel_out);
}

