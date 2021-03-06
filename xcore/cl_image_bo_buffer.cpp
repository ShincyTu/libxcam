/*
 * cl_image_bo_buffer.cpp - cl image bo buffer
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
 */

#include "cl_image_bo_buffer.h"
#include "cl_memory.h"

namespace XCam {

CLImageBoData::CLImageBoData (SmartPtr<DrmDisplay> &display, SmartPtr<CLImage> &image, drm_intel_bo *bo)
    : DrmBoData (display, bo)
    , _image (image)
{
    XCAM_ASSERT (image->get_mem_id ());
}

CLImageBoBuffer::CLImageBoBuffer (const VideoBufferInfo &info, const SmartPtr<CLImageBoData> &data)
    : DrmBoBuffer (info, data)
{
}

CLBoBufferPool::CLBoBufferPool (SmartPtr<DrmDisplay> &display, SmartPtr<CLContext> &context)
    : DrmBoBufferPool (display)
    , _context (context)
{
    XCAM_ASSERT (context.ptr ());
    XCAM_LOG_DEBUG ("CLBoBufferPool constructed");
}

CLBoBufferPool::~CLBoBufferPool ()
{
    XCAM_LOG_DEBUG ("CLBoBufferPool destructed");
}

SmartPtr<CLImageBoData>
CLBoBufferPool::create_image_bo (const VideoBufferInfo &info)
{
    int32_t mem_fd = -1;
    SmartPtr<DrmDisplay> display = get_drm_display ();
    drm_intel_bo *bo = NULL;
    CLImageDesc desc;
    SmartPtr<CLImageBoData> data;
    SmartPtr<CLImage> image = new CLImage2D (_context, info, CL_MEM_READ_WRITE);
    XCAM_FAIL_RETURN (
        WARNING,
        image.ptr () && image->get_mem_id (),
        NULL,
        "CLBoBufferPool create image failed");

    desc = image->get_image_desc ();
    mem_fd = image->export_fd ();
    XCAM_FAIL_RETURN (
        WARNING,
        mem_fd < 0,
        NULL,
        "CLBoBufferPool export image fd failed");

    bo = display->create_drm_bo_from_fd (mem_fd, desc.size);
    XCAM_FAIL_RETURN (
        WARNING,
        bo,
        NULL,
        "CLBoBufferPool bind fd to bo failed");

    data = new CLImageBoData (display, image, bo);
    XCAM_FAIL_RETURN (
        WARNING,
        data.ptr (),
        NULL,
        "CLBoBufferPool bind CLImage to CLImageBoData failed");
    return data;
}

bool
CLBoBufferPool::fixate_video_info (VideoBufferInfo &info)
{
    SmartPtr<CLImage> image;
    SmartPtr<CLImageBoData> image_data = create_image_bo (info);
    XCAM_FAIL_RETURN (
        WARNING,
        image_data.ptr (),
        NULL,
        "CLBoBufferPool fixate_video_info failed");

    image = image_data->get_image ();
    XCAM_ASSERT (image.ptr ());

    CLImageDesc desc = image->get_image_desc ();
    if (desc.row_pitch != info.strides[0] || desc.size != info.size) {
        uint32_t aligned_width = desc.row_pitch / image->get_pixel_bytes ();
        info.init (info.format, info.width, info.height, aligned_width, 0, desc.size);
    }

    add_data_unsafe (image_data);

    return true;
}

SmartPtr<BufferData>
CLBoBufferPool::allocate_data (const VideoBufferInfo &buffer_info)
{
    SmartPtr<CLImageBoData> image_data = create_image_bo (buffer_info);
    return image_data;
}

SmartPtr<BufferProxy>
CLBoBufferPool::create_buffer_from_data (SmartPtr<BufferData> &data)
{
    const VideoBufferInfo & info = get_video_info ();
    SmartPtr<CLImageBoData> image_data = data.dynamic_cast_ptr<CLImageBoData> ();
    XCAM_ASSERT (image_data.ptr ());

    return new CLImageBoBuffer (info, image_data);
}


};
