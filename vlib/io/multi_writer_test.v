module io

fn test_multi_writer_write_successful() {
	w0 := TestWriter{}
	w1 := TestWriter{}
	mw := new_multi_writer(w0, w1)
	n := mw.write('0123456789'.bytes()) or {
		assert false
		return
	}
	assert n == 10
	assert w0.bytes == '0123456789'.bytes()
	assert w1.bytes == '0123456789'.bytes()
}

fn test_multi_writer_write_incomplete() {
	w0 := TestWriter{}
	w1 := TestIncompleteWriter{}
	mw := new_multi_writer(w0, w1)
	n := mw.write('0123456789'.bytes()) or {
		assert w0.bytes == '0123456789'.bytes()
		assert w1.bytes == '012345678'.bytes()
		return
	}
	assert false
}

fn test_multi_writer_write_error() {
	w0 := TestWriter{}
	w1 := TestErrorWriter{}
	w2 := TestWriter{}
	mw := new_multi_writer(w0, w1, w2)
	n := mw.write('0123456789'.bytes()) or {
		assert w0.bytes == '0123456789'.bytes()
		assert w2.bytes == []
		return
	}
	assert false
}

struct TestWriter {
pub mut:
	bytes []byte
}

fn (mut w TestWriter) write(buf []byte) ?int {
	w.bytes << buf
	return buf.len
}

struct TestIncompleteWriter {
pub mut:
	bytes []byte
}

fn (mut w TestIncompleteWriter) write(buf []byte) ?int {
	b := buf[..buf.len - 1]
	w.bytes << b
	return b.len
}

struct TestErrorWriter {}

fn (mut w TestErrorWriter) write(buf []byte) ?int {
	return error('error writer errored')
}
