# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: tensorflow/core/protobuf/master_service.proto for package 'tensorflow.grpc'
# Original file comments:
# Copyright 2016 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#

require 'grpc'
require 'tensorflow/core/protobuf/master_service_pb'

module Tensorflow
  module Grpc
    module MasterService
      # //////////////////////////////////////////////////////////////////////////////
      #
      # MasterService defines a TensorFlow service with which a client can
      # interact to execute a distributed TensorFlow computation.
      #
      # A master service keeps track of multiple "master sessions". Each
      # session encapsulates a computation graph and its associated state,
      # and typically corresponds to a single "client session" (e.g. a
      # `tensorflow::Session` instance).
      #
      # A session is responsible for the following:
      # * assigning each node to a device (locally or remotely) using a
      #   placement algorithm. This may make decisions based on collected
      #   statistics from the workers in the system (e.g., memory usage,
      #   bandwidth consumption, etc.)
      #
      # * inserting intermediate nodes and edges to support cross-device
      #   and cross-process data flows and resource management.
      #
      # * issuing commands to workers to execute the subgraphs associated
      #   with those workers.
      #
      # Typically, a client carries out an iterative computation
      # (e.g. training) by invoking RPCs against the master in a
      # client-side loop. The client first creates a client session that
      # connects to a particular master (using gRPC for example). The
      # master creates a corresponding master session that is hosted on
      # the master and caches state between the client's invocations.
      #
      # After the session is established, the master returns an opaque
      # handle to the client that can be used to associate the client and
      # master sessions.
      #
      # The client may send an initial graph to the master in the
      # CreateSession call, and add nodes to the graph using ExtendSession.
      #
      # The most frequent operation a master is "RunStep", which implements
      # the `Session::Run()` API. It supports feeding in arguments,
      # executing a dataflow computation, and fetching arguments.
      #
      # Finally, when the client no longer needs the session, it should
      # close the session by invoking CloseSession, which allows the master
      # to reclaim resources associated with the session. The master may
      # implement a garbage collection scheme that closes sessions that
      # have been inactive for some time.
      #
      # For example, the following pseudo-code illustrates how a client
      # interacts with a master:
      #
      # stub = NewStub("/job:mnist/replica:0/task:0")
      # {handle} = stub->CreateSession({graph_def})
      # do {
      #   stub->RunStep({handle, {feeds}, {fetches}})
      #   // The client can evaluate a predicate locally, based on the
      #   // result of `fetches`, to determine whether to terminate. For
      #   // example, it might fetch the loss and evaluate whether it is less
      #   // than some threshold.
      # } whlie (!should_stop({fetches}));
      # stub->CloseSession({handle})
      #
      # //////////////////////////////////////////////////////////////////////////////
      #
      class Service

        include GRPC::GenericService

        self.marshal_class_method = :encode
        self.unmarshal_class_method = :decode
        self.service_name = 'tensorflow.grpc.MasterService'

        # Creates a session.
        rpc :CreateSession, Tensorflow::CreateSessionRequest, Tensorflow::CreateSessionResponse
        # Extends a session.
        rpc :ExtendSession, Tensorflow::ExtendSessionRequest, Tensorflow::ExtendSessionResponse
        # Prepares future partial run calls.
        rpc :PartialRunSetup, Tensorflow::PartialRunSetupRequest, Tensorflow::PartialRunSetupResponse
        # Drives the graph computation.
        rpc :RunStep, Tensorflow::RunStepRequest, Tensorflow::RunStepResponse
        # Closes a session.
        rpc :CloseSession, Tensorflow::CloseSessionRequest, Tensorflow::CloseSessionResponse
        # List the devices usable by the master.
        rpc :ListDevices, Tensorflow::ListDevicesRequest, Tensorflow::ListDevicesResponse
        # Close all existing sessions.
        rpc :Reset, Tensorflow::ResetRequest, Tensorflow::ResetResponse
      end

      Stub = Service.rpc_stub_class
    end
  end
end
