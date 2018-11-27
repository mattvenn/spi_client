SHELL = bash

formal_spi: spi_client.v
	sby -f spi.sby

.PHONY: all clean
