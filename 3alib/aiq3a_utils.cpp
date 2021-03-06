/*
 * aiq3a_util.cpp - aiq 3a utility:
 *
 *  Copyright (c) 2015 Intel Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Wind Yuan <feng.yuan@intel.com>
 * Author: Shincy Tu <shincy.tu@intel.com>
 */

#include "aiq3a_utils.h"
#include "x3a_isp_config.h"

using namespace XCam;

namespace XCamAiq3A {

bool
translate_3a_stats (XCam3AStats *from, struct atomisp_3a_statistics *to)
{
    XCAM_ASSERT (from);
    XCAM_ASSERT (to);

    struct atomisp_grid_info &to_info = to->grid_info;
    XCam3AStatsInfo &from_info = from->info;
    uint32_t color_count = (from_info.grid_pixel_size / 2) * (from_info.grid_pixel_size / 2);

    XCAM_ASSERT (to_info.bqs_per_grid_cell == 8);

    for (uint32_t i = 0; i < from_info.height; ++i)
        for (uint32_t j = 0; j < from_info.width; ++j) {
            to->data [i * to_info.aligned_width + j].ae_y =
                from->stats [i * from_info.aligned_width + j].avg_y * color_count;
            to->data [i * to_info.aligned_width + j].awb_gr =
                from->stats [i * from_info.aligned_width + j].avg_gr * color_count;
            to->data [i * to_info.aligned_width + j].awb_r =
                from->stats [i * from_info.aligned_width + j].avg_r * color_count;
            to->data [i * to_info.aligned_width + j].awb_b =
                from->stats [i * from_info.aligned_width + j].avg_b * color_count;
            to->data [i * to_info.aligned_width + j].awb_gb =
                from->stats [i * from_info.aligned_width + j].avg_gb * color_count;
            to->data [i * to_info.aligned_width + j].awb_cnt =
                from->stats [i * from_info.aligned_width + j].valid_wb_count;
            to->data [i * to_info.aligned_width + j].af_hpf1 =
                from->stats [i * from_info.aligned_width + j].f_value1;
            to->data [i * to_info.aligned_width + j].af_hpf2 =
                from->stats [i * from_info.aligned_width + j].f_value2;
        }
    return true;
}

void
matrix_3x3_mutiply (double *dest, const double *src1, const double *src2)
{
    dest[0] = src1[0] * src2[0] + src1[1] * src2[3] + src1[2] * src2[6];
    dest[1] = src1[0] * src2[1] + src1[1] * src2[4] + src1[2] * src2[7];
    dest[2] = src1[0] * src2[2] + src1[1] * src2[5] + src1[2] * src2[8];

    dest[3] = src1[3] * src2[0] + src1[4] * src2[3] + src1[5] * src2[6];
    dest[4] = src1[3] * src2[1] + src1[4] * src2[4] + src1[5] * src2[7];
    dest[5] = src1[3] * src2[2] + src1[4] * src2[5] + src1[5] * src2[8];

    dest[6] = src1[6] * src2[0] + src1[7] * src2[3] + src1[8] * src2[6];
    dest[7] = src1[6] * src2[1] + src1[7] * src2[4] + src1[8] * src2[7];
    dest[8] = src1[6] * src2[2] + src1[7] * src2[5] + src1[8] * src2[8];
}

uint32_t
translate_atomisp_parameters (
    const struct atomisp_parameters &atomisp_params,
    XCam3aResultHead *results[], uint32_t max_count)
{
    uint32_t result_count = 0;
    double coefficient = 0.0;

    /* Translation for white balance */
    XCAM_ASSERT (result_count < max_count);
    if (atomisp_params.wb_config) {
        XCam3aResultWhiteBalance *wb = xcam_malloc0_type (XCam3aResultWhiteBalance);
        wb->head.type = XCAM_3A_RESULT_WHITE_BALANCE;
        wb->head.process_type = XCAM_IMAGE_PROCESS_ALWAYS;
        wb->head.version = XCAM_VERSION;
        coefficient = pow (2, (16 - atomisp_params.wb_config->integer_bits));
        wb->r_gain = atomisp_params.wb_config->r / coefficient;
        wb->gr_gain = atomisp_params.wb_config->gr / coefficient;
        wb->gb_gain = atomisp_params.wb_config->gb / coefficient;
        wb->b_gain = atomisp_params.wb_config->b / coefficient;
        results[result_count++] = (XCam3aResultHead*)wb;
    }

    /* Translation for black level correction */
    XCAM_ASSERT (result_count < max_count);
    if (atomisp_params.ob_config) {
        XCam3aResultBlackLevel *blc = xcam_malloc0_type (XCam3aResultBlackLevel);
        blc->head.type =    XCAM_3A_RESULT_BLACK_LEVEL;
        blc->head.process_type = XCAM_IMAGE_PROCESS_ALWAYS;
        blc->head.version = XCAM_VERSION;
        if (atomisp_params.ob_config->mode == atomisp_ob_mode_fixed) {
            blc->r_level = atomisp_params.ob_config->level_r / (double)65536;
            blc->gr_level = atomisp_params.ob_config->level_gr / (double)65536;
            blc->gb_level = atomisp_params.ob_config->level_gb / (double)65536;
            blc->b_level = atomisp_params.ob_config->level_b / (double)65536;
        }
        results[result_count++] = (XCam3aResultHead*)blc;
    }

    /* Translation for color correction */
    XCAM_ASSERT (result_count < max_count);
    if (atomisp_params.yuv2rgb_cc_config) {
        static const double rgb2yuv_matrix [XCAM_COLOR_MATRIX_SIZE] = {
            0.299, 0.587, 0.114,
            -0.14713, -0.28886, 0.436,
            0.615, -0.51499, -0.10001
        };
        static const double r_ycgco_matrix [XCAM_COLOR_MATRIX_SIZE] = {
            0.25, 0.5, 0.25,
            -0.25, 0.5, -0.25,
            0.5, 0, -0.5
        };

        double tmp_matrix [XCAM_COLOR_MATRIX_SIZE] = {0.0};
        double cc_matrix [XCAM_COLOR_MATRIX_SIZE] = {0.0};
        XCam3aResultColorMatrix *cm = xcam_malloc0_type (XCam3aResultColorMatrix);
        cm->head.type = XCAM_3A_RESULT_RGB2YUV_MATRIX;
        cm->head.process_type = XCAM_IMAGE_PROCESS_ALWAYS;
        cm->head.version = XCAM_VERSION;
        coefficient = pow (2, atomisp_params.yuv2rgb_cc_config->fraction_bits);
        for (int i = 0; i < XCAM_COLOR_MATRIX_SIZE; i++) {
            tmp_matrix [i] = atomisp_params.yuv2rgb_cc_config->matrix [i] / coefficient;
        }
        matrix_3x3_mutiply (cc_matrix, tmp_matrix, r_ycgco_matrix);
        matrix_3x3_mutiply (cm->matrix, rgb2yuv_matrix, cc_matrix);
        //results = yuv2rgb_matrix * tmp_matrix * r_ycgco_matrix
        results[result_count++] = (XCam3aResultHead*)cm;
    }

    /* Translation for gamma table */
    XCAM_ASSERT (result_count < max_count);
    if (atomisp_params.g_gamma_table) {
        XCam3aResultGammaTable *gt = xcam_malloc0_type (XCam3aResultGammaTable);
        gt->head.type = XCAM_3A_RESULT_G_GAMMA;
        gt->head.process_type = XCAM_IMAGE_PROCESS_ALWAYS;
        gt->head.version = XCAM_VERSION;
        for (int i = 0; i < XCAM_GAMMA_TABLE_SIZE; i++) {
            gt->table[i] = (double)atomisp_params.g_gamma_table->data.vamem_2[i] / 16;
        }
        results[result_count++] = (XCam3aResultHead*)gt;
    }

    /* Translation for macc matrix table */
    XCAM_ASSERT (result_count < max_count);
    if (atomisp_params.macc_config) {
        XCam3aResultMaccMatrix *macc = xcam_malloc0_type (XCam3aResultMaccMatrix);
        macc->head.type = XCAM_3A_RESULT_MACC;
        macc->head.process_type = XCAM_IMAGE_PROCESS_ALWAYS;
        macc->head.version = XCAM_VERSION;
        coefficient = pow (2, (13 - atomisp_params.macc_config->color_effect));
        for (int i = 0; i < XCAM_CHROMA_AXIS_SIZE * XCAM_CHROMA_MATRIX_SIZE; i++) {
            macc->table[i] = (double)atomisp_params.macc_table->data[i] / coefficient;
        }
        results[result_count++] = (XCam3aResultHead*)macc;
    }

    /* Translation for defect pixel correction */
    XCAM_ASSERT (result_count < max_count);
    if (atomisp_params.dp_config) {
        XCam3aResultDefectPixel *dpc = xcam_malloc0_type (XCam3aResultDefectPixel);
        dpc->head.type = XCAM_3A_RESULT_DEFECT_PIXEL_CORRECTION;
        dpc->head.process_type = XCAM_IMAGE_PROCESS_ALWAYS;
        dpc->head.version = XCAM_VERSION;
        coefficient = pow (2, 16);
        dpc->gr_threshold = atomisp_params.dp_config->threshold / coefficient;
        dpc->r_threshold = atomisp_params.dp_config->threshold / coefficient;
        dpc->b_threshold = atomisp_params.dp_config->threshold / coefficient;
        dpc->gb_threshold = atomisp_params.dp_config->threshold / coefficient;
        results[result_count++] = (XCam3aResultHead*)dpc;
    }

    return result_count;
}

uint32_t
translate_3a_results_to_xcam (X3aResultList &list,
                              XCam3aResultHead *results[], uint32_t max_count)
{
    uint32_t result_count = 0;
    for (X3aResultList::iterator iter = list.begin (); iter != list.end (); ++iter) {
        SmartPtr<X3aResult> &isp_result = *iter;

        switch (isp_result->get_type()) {
        case X3aIspConfig::IspExposureParameters: {
            SmartPtr<X3aIspExposureResult> isp_exposure =
                isp_result.dynamic_cast_ptr<X3aIspExposureResult> ();
            XCAM_ASSERT (isp_exposure.ptr ());
            const XCam3aResultExposure &exposure = isp_exposure->get_standard_result ();
            XCam3aResultExposure *new_exposure = xcam_malloc0_type (XCam3aResultExposure);
            *new_exposure = exposure;
            new_exposure->head.type = XCAM_3A_RESULT_EXPOSURE;
            new_exposure->head.process_type = XCAM_IMAGE_PROCESS_ALWAYS;
            new_exposure->head.version = XCAM_VERSION;
            results[result_count++] = (XCam3aResultHead*)new_exposure;
            break;
        }
        case X3aIspConfig::IspAllParameters: {
            SmartPtr<X3aAtomIspParametersResult> isp_3a_all =
                isp_result.dynamic_cast_ptr<X3aAtomIspParametersResult> ();
            XCAM_ASSERT (isp_3a_all.ptr ());
            const struct atomisp_parameters &atomisp_params = isp_3a_all->get_isp_config ();
            result_count += translate_atomisp_parameters (atomisp_params, &results[result_count], max_count - result_count);
            break;
        }
        default:
            XCAM_LOG_WARNING ("unknow type(%d) in translation", isp_result->get_type());
            break;
        }
    }
    return result_count;
}

void
free_3a_result (XCam3aResultHead *result)
{
    xcam_free (result);
}

}
