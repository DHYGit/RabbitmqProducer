CC=gcc
CXX=g++
INC_PATH= ./

O_FLAG = -O0
CFLAGS    += ${O_FLAG} -L $(PCAP_CFLAGS) -Wno-deprecated -Wall
LDFLAGS    = -L $(PCAPLIB) $(LIBLINEAR) -L/usr/lib -lpthread -lrabbitmq
CFLAGS += -I$(INC_PATH) $(INCLUDE) -g -std=c++11

# ����ļ���
TARGET= producer
OUTPUT_PATH = ./obj


#����VPATH ����Դ�����Ŀ¼�б�
#����Դ�ļ�
SUBINC = .

#����ͷ�ļ�
SUBDIR = .

#����VPATH
INCLUDE = $(foreach n, $(SUBINC), -I$(INC_PATH)/$(n)) 
SPACE =  
VPATH = $(subst $(SPACE),, $(strip $(foreach n,$(SUBDIR), $(INC_PATH)/$(n)))) $(OUTPUT_PATH)

C_SOURCES = $(notdir $(foreach n, $(SUBDIR), $(wildcard $(INC_PATH)/$(n)/*.c)))
CPP_SOURCES = $(notdir $(foreach n, $(SUBDIR), $(wildcard $(INC_PATH)/$(n)/*.cpp)))

C_OBJECTS = $(patsubst  %.c,  $(OUTPUT_PATH)/%.o, $(C_SOURCES))
CPP_OBJECTS = $(patsubst  %.cpp,  $(OUTPUT_PATH)/%.o, $(CPP_SOURCES))

CXX_SOURCES = $(CPP_SOURCES) $(C_SOURCES)
CXX_OBJECTS = $(CPP_OBJECTS) $(C_OBJECTS) 


$(TARGET):$(CXX_OBJECTS)
	$(CXX) -o $@ $(foreach n, $(CXX_OBJECTS), $(n)) $(foreach n, $(OBJS), $(n))  $(LDFLAGS) 
	#******************************************************************************#
	#                               Bulid successful !                             #
	#******************************************************************************#
	
$(OUTPUT_PATH)/%.o:%.cpp
	$(CXX) $< -c $(CFLAGS) -o $@
	
$(OUTPUT_PATH)/%.o:%.c
	$(CC) $< -c $(CFLAGS) -o $@

mkdir:
	mkdir -p $(dir $(TARGET))
	mkdir -p $(OUTPUT_PATH)
	
rmdir:
	rm -rf $(dir $(TARGET))
	rm -rf $(OUTPUT_PATH)

clean:
	rm -f $(OUTPUT_PATH)/*
	rm -rf $(TARGET)
