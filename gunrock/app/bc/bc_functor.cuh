#pragma once

#include <gunrock/app/problem_base.cuh>
#include <gunrock/app/bc/bc_problem.cuh>

namespace gunrock {
namespace app {
namespace bc {

template<typename VertexId, typename SizeT, typename Value, typename ProblemData>
struct ForwardFunctor
{
    typedef typename ProblemData::DataSlice DataSlice;

    static __device__ __forceinline__ bool CondEdge(VertexId s_id, VertexId d_id, DataSlice *problem)
    {
        // Check if the destination node has been claimed as someone's child
        bool child_available = (atomicCAS(&problem->d_preds[d_id], -2, s_id) == -2) ? true : false;
        if (child_available)
        {
            VertexId label;
            util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
                    label, problem->d_labels + s_id);
            util::io::ModifiedStore<ProblemData::QUEUE_WRITE_MODIFIER>::St(
                    label+1, problem->d_labels + d_id);
        }
        VertexId s_label;
        VertexId d_label;
        util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
                s_label, problem->d_labels + s_id);
        util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
                d_label, problem->d_labels + d_id);
        if (d_label == s_label + 1)
        {
            //Accumulate sigma value
            atomicAdd(&problem->d_sigmas[d_id], problem->d_sigmas[s_id]);
        }
        return child_available;

    }

    static __device__ __forceinline__ void ApplyEdge(VertexId s_id, VertexId d_id, DataSlice *problem)
    {
        
        //for simple BC, Apply doing nothing
        
    }

    static __device__ __forceinline__ bool CondVertex(VertexId node, DataSlice *problem)
    {
        return node != -1;
    }

    static __device__ __forceinline__ void ApplyVertex(VertexId node, DataSlice *problem)
    {
        // Doing nothing here
    }
};

template<typename VertexId, typename SizeT, typename Value, typename ProblemData>
struct BackwardFunctor
{
    typedef typename ProblemData::DataSlice DataSlice;

    static __device__ __forceinline__ bool CondEdge(VertexId s_id, VertexId d_id, DataSlice *problem)
    {
        
        VertexId s_label;
        VertexId d_label;
        util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
                s_label, problem->d_labels + s_id);
        util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
                d_label, problem->d_labels + d_id);
       return (d_label == s_label + 1);
    }

    static __device__ __forceinline__ void ApplyEdge(VertexId s_id, VertexId d_id, DataSlice *problem)
    {
        //for simple BC, Apply doing nothing
        //set d_labels[d_id] to be d_labels[s_id]+1
        Value from_sigma;
        util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
            from_sigma, problem->d_sigmas + s_id);

        Value to_sigma;
        util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
            to_sigma, problem->d_sigmas + d_id);

        Value to_delta;
        util::io::ModifiedLoad<ProblemData::COLUMN_READ_MODIFIER>::Ld(
            to_delta, problem->d_deltas + d_id);

        Value result = from_sigma / to_sigma * (1.0 + to_delta);

        //Accumulate delta value
        atomicAdd(&problem->d_deltas[s_id], result);

        //Accumulate bc value
        atomicAdd(&problem->d_bc_values[s_id], result);
    }

    static __device__ __forceinline__ bool CondVertex(VertexId node, DataSlice *problem)
    {
        return problem->d_labels[node] == 0;
    }

    static __device__ __forceinline__ void ApplyVertex(VertexId node, DataSlice *problem)
    {
        // Doing nothing here
    }
};

} // bc
} // app
} // gunrock