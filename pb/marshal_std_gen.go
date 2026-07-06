//go:build !js

package pb

import (
	"google.golang.org/protobuf/proto"
)

func (m *Error) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *Error) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *Cancel) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *Cancel) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *Done) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *Done) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *Init) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *Init) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *ReverseResponse) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *ReverseResponse) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *Request) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *Request) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *Response) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *Response) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *RpcRequest) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *RpcRequest) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *RpcResponse) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *RpcResponse) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}

func (m *Push) MarshalVT() ([]byte, error) {
	return proto.Marshal(m)
}

func (m *Push) UnmarshalVT(b []byte) error {
	return proto.Unmarshal(b, m)
}
