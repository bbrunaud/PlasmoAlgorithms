import Plasmo.getgraph

function normalizegraph(graph::ModelGraph)
    n = 1
    for node in getnodes(graph)
        m = getmodel(node)
        if m.objSense == :Max
            m.objSense = :Min
            m.obj = -m.obj
            n = -1
        end
    end
    setattribute(graph, :normalized, n)
    return n
end

function fix(var::JuMP.Variable,value::Real)
  setlowerbound(var,value)
  setupperbound(var,value)
end

"""
Checks if n1 is a child node of n2
"""
ischildnode(graph::ModelGraph, n1::ModelNode, n2::ModelNode) = in(n2,in_neighbors(graph,n1))

function savenodeobjective(mf::JuMP.Model)
    g = mf.ext[:Graph]
    numnodes = length(getnodes(g))
    nodeindex = Dict("node$i" => i for i in 1:numnodes)
    nov = mf.ext[:nodeobj] = [AffExpr(0.0) for i in 1:numnodes]
    obj = mf.obj.aff
    for (i,var) in enumerate(obj.vars)
        coeff = obj.coeffs[i]
        varname = mf.colNames[var.col]
        nodename = varname[1:search(varname,'.')-1]
        index = nodeindex[nodename]
        push!(nov[index],coeff,var)
    end
end

function getnodeindex(node::Plasmo.PlasmoModels.ModelNode)
    indexdict = node.basenode.indices
    length(indexdict) > 1 && error("More than one index found for node")
    return collect(values(node.basenode.indices))[1]
end

function getgraph(node::Plasmo.PlasmoModels.ModelNode)
    indexdict = node.basenode.indices
    length(indexdict) > 1 && error("More than one index found for node")
    return collect(keys(node.basenode.indices))[1]
end

function subgraphobjective(node, graph)
    if out_degree(graph, node) == 0
        return getobjectivevalue(getmodel(node))
    end
    return getobjectivevalue(getmodel(node)) + sum(subgraphobjective(childnode, graph) for childnode in out_neighbors(graph, node))
end
