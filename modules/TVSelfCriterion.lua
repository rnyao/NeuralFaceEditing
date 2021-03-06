require 'nn'
require 'torch'

local TVSelfCriterion, parent = torch.class('nn.TVSelfCriterion', 'nn.Criterion')

function TVSelfCriterion:__init(strength)
    parent.__init(self)
    self.strength = 0.1
    --self.x_diff = torch.Tensor()
    --self.y_diff = torch.Tensor()
    self.nSample = 1
end

local function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function TVSelfCriterion:updateOutput(input)

    local x_diff = input[{{}, {}, {1, -2}, {1, -2}}] - input[{{}, {}, {1, -2}, {2, -1}}]
    local y_diff = input[{{}, {}, {1, -2}, {1, -2}}] - input[{{}, {}, {2, -1}, {1, -2}}]

    local m = self.strength
    m = m/input:nElement()

    local loss = (x_diff:norm(1)+y_diff:norm(1))*m

    self.output = loss
    return self.output

end

-- TV loss backward pass inspired by kaishengtai/neuralart
function TVSelfCriterion:updateGradInput(input)
    
    
    
    local m = self.strength
    m = m/input:nElement()

    local x_diff = input[{{}, {}, {1, -2}, {1, -2}}] - input[{{}, {}, {1, -2}, {2, -1}}]
    local y_diff = input[{{}, {}, {1, -2}, {1, -2}}] - input[{{}, {}, {2, -1}, {1, -2}}]


    local grad = input.new():resize(input:size()):zero()
    
    grad[{{}, {}, {1, -2}, {1, -2}}]:add(torch.sign(x_diff)):add(torch.sign(y_diff))
    grad[{{}, {}, {1, -2}, {2, -1}}]:add(-1, torch.sign(x_diff))
    grad[{{}, {}, {2, -1} ,{1, -2}}]:add(-1, torch.sign(y_diff))

    self.gradInput = grad*m
    
    return self.gradInput
end