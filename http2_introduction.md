## Testing

[h2spec](https://github.com/summerwind/h2spec)

### HTTP/2 spec
[RFC7540](http://httpwg.org/specs/rfc7540.html)

### Hpack spec
[RFC7541](http://httpwg.org/specs/rfc7541.html)

### Packet capture
[Capture HTTP/2 by Wishark](https://github.com/billfeller/billfeller.github.io/issues/121)

How to setup
```
git clone https://github.com/summerwind/h2spec.git
cd h2spec
go get github.com/spf13/cobra
go get github.com/summerwind/h2spec
go run cmd/h2spec/h2spec.go -p 8000 http2
```