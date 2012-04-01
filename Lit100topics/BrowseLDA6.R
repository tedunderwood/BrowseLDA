# Load metadata.
DummyVar <- readline("Ready to select Metadata file? (you don't have to say 'y,' just hit return) ")
cat('\n')
file <- file.choose()

Metadata <- read.table(file, header = TRUE, stringsAsFactors=FALSE, sep = '\t', fill = TRUE, nrows = 6400, quote = '"')

Documents <- Metadata$V1
TotalsPerDoc <- as.integer(Metadata$V8)
names(TotalsPerDoc) <- Documents
Titles <- paste(substr(Metadata$V9, 1, 25), Documents)
names(Titles) <- Documents
LongTitles <- Metadata$V9
names(LongTitles) <- Documents
Authors <- Metadata$V3
names(Authors) <- Documents
DocDates <- as.numeric(Metadata$V4)
names(DocDates) <- Documents
Genres <- Metadata$V5
names(Genres) <- Documents

DummyVar <- readline("Ready to select Phi (topic distributions over words)? ")
cat('\n')
file <- file.choose()

FileLines <- readLines(con = file, n = -1, encoding = "UTF-8")
TopicCount <- as.integer(FileLines[1])
FileLines <- FileLines[-1]

Topic = 1
Phi <- vector("list", TopicCount)
for (Line in FileLines) {
	Prefix <- substr(Line, 1, 5)
	if (Prefix == "Topic") next
	if (Prefix == "-----") {
		Topic = Topic + 1
		next
		}
	Phi[[Topic]] <- c(Phi[[Topic]], Line)
	}

AllWords <- character(0)
for (i in 1: TopicCount) {
	AllWords <- union(AllWords, Phi[[i]])
	}

DummyVar <- readline("Ready to select KL file (topic relations to each other)? ")
cat('\n')
file <- file.choose()

FileLines <- readLines(con = file, n = -1, encoding = "UTF-8")

KL <- vector("list", TopicCount)
Topic = 0
for (Line in FileLines) {
	Prefix <- substr(Line, 1, 5)
	if (Prefix == "Topic") {
		Topic = Topic + 1
		next
		}
	Connection <- as.integer(Line)
	if (Connection == (Topic - 1) ) next
	else KL[[Topic]] <- c(KL[[Topic]], Connection)
	}

DummyVar <- readline("Ready to select Theta file (topic relations to documents)? ")
cat('\n')
file <- file.choose()
	
Theta <- as.matrix(read.table(file, sep = ","))
cat('Theta read in. Now processing document information; may take 5 min.\n\n')

# Create topic sizes.
TopicSize <- integer(TopicCount)
for (i in 1: TopicCount) {
	TopicSize[i] <- sum(Theta[i, ])
	}

# Rank topics
TopicBulk <- TopicSize
TopicRanks <- integer(TopicCount)
names(TopicSize) <- 1:TopicCount
TopicSize <- sort(TopicSize, decreasing = TRUE)
for (i in 1: TopicCount) {
	TopicRanks[i] <- which(names(TopicSize) == as.character(i))
	}

NumDocs <- length(Documents)

MinDate = min(DocDates)
MaxDate = max(DocDates)
Timespan = (MaxDate - MinDate) + 1
TotalsPerYear <- integer(Timespan)

for (i in 1: NumDocs) {
	DateIndex = (DocDates[i] - MinDate) + 1
	TotalsPerYear[DateIndex] = TotalsPerYear[DateIndex] + TotalsPerDoc[i]
	}

TotalsPerYear[TotalsPerYear < 1] = 1

ThetaSum <- array(data=0, dim = c(TopicCount, Timespan))
for (i in 1: NumDocs) {
	DateIndex = (DocDates[i] - MinDate) + 1
	ThetaSum[ , DateIndex] = ThetaSum[ , DateIndex] + Theta[ , i]
	}

for (i in 1: TopicCount) {
	HoldVector = ThetaSum[i ,] / TotalsPerYear
	HoldVector[HoldVector == 0] <- NA
	ThetaSum[i ,] <- HoldVector
	}

# This turns absolute occurrences into proportions per document.
Dimensions <- dim(Theta)
for (i in 1: TopicCount) {
	Theta[i, ] <- Theta[i, ] / TotalsPerDoc
	}

display.topic <- function(TopicNum) {
	Freqs <- Theta[TopicNum, ]
	names(Freqs) <- 1:Dimensions[2]
	Freqs <- sort(Freqs, decreasing = TRUE)
	Top30 <- as.integer(names(Freqs[1:30]))
	for (DocNum in Top30) {
		cat(Documents[DocNum], Authors[DocNum], DocDates[DocNum], Genres[DocNum], TotalsPerDoc[DocNum], '\n')
		cat(LongTitles[DocNum],'\n','\n')
		}
	}

repeat {
	Proceed = FALSE
	while (!Proceed) {
		Word <- readline('Enter a word, a DocID, or a topic# (*topic# to see a longer doc list): ')
		if (substr(Word,1,1) == "*") {
			display.topic(as.integer(substr(Word,2,6)))
			next
			}
		TopNum <- suppressWarnings(as.integer(Word))
		if (!is.na(TopNum) | Word %in% AllWords | Word %in% Documents) Proceed = TRUE
		else cat("That wasn't a valid entry, perhaps because we don't have that word.", '\n')
		}
	
	# The following section deals with the case where the user has
	# entered a word to look up.
	
	if (Word %in% AllWords) {
		Hits <- numeric(0)
		NumHits <- 0
		Indices <- numeric(0)
		for (i in 1: TopicCount) {
			if (Word %in% Phi[[i]]) {
				NumHits <- NumHits + 1
				Hits <- c(Hits, which(Phi[[i]] == Word))
				Indices <- c(Indices, i)
				}
			}
		names(Hits) <- Indices
		Hits <- sort(Hits, decreasing = FALSE)
		cat('\n')
		if (NumHits > 5) NumHits <- 5
		for (i in 1: NumHits) {
			Top <- as.integer(names(Hits[i]))
			cat("Topic", Top, ":", Phi[[Top]][1], Phi[[Top]][2], Phi[[Top]][3], Phi[[Top]][4], Phi[[Top]][5], Phi[[Top]][6], '\n')
			}
		User <- readline('Which of these topics do you select? ')
		TopNum <- as.integer(User)
		if (is.na(TopNum)) TopNum <- 1
		}
	else if (Word %in% Documents) {
		DocIndex <- which(Documents == Word)
		TopicVector <- Theta[ , DocIndex]
		names(TopicVector) <- 1:TopicCount
		TopicVector <- sort(TopicVector, decreasing = TRUE)
		Top10 <- as.integer(names(TopicVector[1:10]))
		for (Top in Top10) {
			cat("Topic", Top, ":", Phi[[Top]][1], Phi[[Top]][2], Phi[[Top]][3], Phi[[Top]][4], Phi[[Top]][5], Phi[[Top]][6], '\n')
		}
		User <- readline('Which of these topics do you select? ')
		TopNum <- as.integer(User)
		if (is.na(TopNum)) TopNum <- 1
		}
		
	if (TopNum < 1) TopNum <- 1
	if (TopNum > TopicCount) TopNum <- TopicCount	
	# By this point we presumably have a valid TopNum.
	
	cat('\n')
	
	Freqs <- Theta[TopNum, ]
	names(Freqs) <- 1:Dimensions[2]
	Freqs <- sort(Freqs, decreasing = TRUE)
	Top10 <- as.integer(names(Freqs[1:10]))
	
	# Generate smoothed curve.
	Smoothed <- numeric(Timespan)
	for (i in 1: Timespan) {
		Start = i-5
		End = i + 5
		if (Start < 1) Start = 1
		if (End > Timespan) End = Timespan
		Smoothed[i] = mean(ThetaSum[TopNum, Start:End], na.rm = TRUE)
		}
	
	Ratio <- max(Theta[TopNum, ])/max(Smoothed)
	Smoothed <- (Smoothed * Ratio)
	Range <- 1: Timespan
	Loess.Smoothed <- loess(Smoothed ~ Range, span = 0.7)
	Predict.Smoothed <- predict(Loess.Smoothed)
	
	Selected <- Theta[TopNum, ]
	Index <- which(Selected > quantile(Selected)[4])
	Selected <- Selected[Index]
	SelectLen <- length(Selected)
	Colours <- character(SelectLen)
	Shapes <- integer(SelectLen)
	
	for (i in 1: SelectLen) {
		Ind <- Index[i]
		if (Ind %in% Top10) Shapes[i] <- 4
		else Shapes[i] <- 1
		Colours[i] <- "gray42"
		if (Genres[Ind] == "poe") Colours[i] <- "mediumorchid2"
		if (Genres[Ind] == "bio") Colours[i] <- "gray3"
		if (Genres[Ind] == "fic") Colours[i] <- "dodgerblue3"
		if (Genres[Ind] == "dra") Colours[i] <- "olivedrab3"
		if (Genres[Ind] == "juv") Colours[i] <- "gold1"
		if (Genres[Ind] == "non") Colours[i] <- "tan4"
		if (Genres[Ind] == "let" | Genres[Ind] == "ora") {
			Colours[i] <- "salmon3"
			Shapes[i] <- 2
			}
		}
	PlotDates <- DocDates[Index]
	
	plot(PlotDates, Selected, col = Colours, pch = Shapes, xlab = "Blue/fic, purple/poe, green/drama, black/bio, brown/nonfic, triangle/letters or orations.", ylab = "Freq of topic in doc.", main = paste('Topic', TopNum, ':', Phi[[TopNum]][1], Phi[[TopNum]][2], Phi[[TopNum]][3], Phi[[TopNum]][4]))
	par(new=TRUE)
	plot(Predict.Smoothed*.7, type = 'l', lwd = 2, col = "gray75", axes = FALSE, ylab = "", xlab = "")
	
	for (DocNum in Top10) {
		cat(Documents[DocNum], Authors[DocNum], DocDates[DocNum], '\n')
		cat(LongTitles[DocNum],'\n','\n')
		}
	
	cat('TOPIC', TopNum,':', Phi[[TopNum]][1:50], '\n')
	cat('OF', TopicCount, 'TOPICS this is #',TopicRanks[TopNum], 'in desc order, with', TopicBulk[TopNum], 'words. Related topics: \n')
	
	for (i in 1:5) {
		Top <- KL[[TopNum]][i] + 1
		cat("Topic", Top, ":", Phi[[Top]][1], Phi[[Top]][2], Phi[[Top]][3], Phi[[Top]][4], Phi[[Top]][5], Phi[[Top]][6], '\n')
		}
	cat('\n')
	}
		
	