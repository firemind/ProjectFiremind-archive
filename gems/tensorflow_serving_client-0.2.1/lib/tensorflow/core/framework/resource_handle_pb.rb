# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: tensorflow/core/framework/resource_handle.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "tensorflow.ResourceHandle" do
    optional :device, :string, 1
    optional :container, :string, 2
    optional :name, :string, 3
    optional :hash_code, :uint64, 4
    optional :maybe_type_name, :string, 5
  end
end

module Tensorflow
  ResourceHandle = Google::Protobuf::DescriptorPool.generated_pool.lookup("tensorflow.ResourceHandle").msgclass
end
