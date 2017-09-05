--
--  Copyright (c) 2016, Facebook, Inc.
--  All rights reserved.
--
--  This source code is licensed under the BSD-style license found in the
--  LICENSE file in the root directory of this source tree. An additional grant
--  of patent rights can be found in the PATENTS file in the same directory.
--
--

local M = {}

local function isvalid(opt, cachePath)
    local imageInfo = torch.load(cachePath)
    if imageInfo.basedir and imageInfo.basedir ~= opt.rgbData then
        return false
    end
    return true
end

function M.create(opt, split)
    local cachePath = paths.concat(opt.gen, opt.dataset .. '.t7')
    local cacheFlowPath = paths.concat(opt.gen, opt.flowDataset .. '.t7')

    if not paths.filep(cachePath) or not isvalid(opt, cachePath) then
        paths.mkdir('gen')
        -- generate rgb-gen file
        local script = paths.dofile(opt.dataset .. '-gen.lua')
        script.exec(opt, cachePath)
    end
    if not paths.filep(cacheFlowPath) or not isvalid(opt, cacheFlowPath) then
        -- generate flow-gen file
        local script = paths.dofile(opt.flowDataset .. '-gen.lua')
        script.exec(opt, cacheFlowPath)
    end

    local imageInfo = torch.load(cachePath)
    local flowInfo = torch.load(cacheFlowPath)

    local Dataset = require('datasets/' .. opt.dataset)
    return Dataset(imageInfo, flowInfo, opt, split)
end

return M
