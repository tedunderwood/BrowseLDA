ReadMe

[Lit150 folder was revised Sunday at 7:30 am; so if you borrowed it before then you got an earlier version.]

There are three topic models in this folder. Two of them are based on fiction, poetry, drama, and biography, as well as some essays. I've labeled this "literature" in full consciousness that it's a slippery word; in fact we're looking at a period where the modern sense of that word is still emerging.

The third topic model is just based on everything I have after 1799.

As you explore these topic models, take the gray "frequency curves" with a pinch of salt. They're meaningful only to the extent that the underlying collection is evenly balanced across time. It is pretty balanced, but I know, e.g., that we need to add more 19c drama and late-19c poetry.

The topics themselves don't depend to the same extent on subtleties of chronological distribution. I find that they're pretty robust; I've run this process about a dozen times now, changing a lot of things, and the same basic patterns keep recurring.

On the other hand, they're not graven on stone and handed down from Mt Zion. They're constructed through a process where you have to make specific choices -- like, how many topics should we have? If you compare Lit100 and Lit150, I think you'll see that a fairly small shift in the number of topics can make a significant difference.

Also, the presence or absence of contrast makes a big difference. You see different patterns in the 19thc-all-genres topic model than you do in fiction/poetry/drama/biography post 1750.

Finally, choice of words makes a difference. We're looking at roughly the top 5000 words in all of these models -- further expansion of the lexicon might make a difference, although I suspect it makes less than one might think.

Topic modeling also tends to work a little better if you exclude words that are very common in the corpus -- what we call a list of "stopwords." The choices you make in defining that list can be significant. For instance, I've excluded "i, me, she, he," among other things, because I didn't want the division between 1st- and 3rd-person fiction to swamp everything else. I left "myself, herself, etc." in because they're slightly less common, and I concluded they would be revealing without doing much harm. But both of those choices are subject to debate.

I excluded personal names, because they really mess things up in fiction otherwise. (Two books that both contain characters named David are not meaningfully similar!) But I didn't exclude place names.

If you want to take a closer look at the underlying documents in order to find a DocID, the BrowseLDA script is going to leave you with a data frame called Metadata. You can sort that data frame using the tricks we learned a few weeks ago in order to, for instance, find a particular author.

Or, probably more simply, you can just load the Metadata file from a given folder into Excel and sort it there. Don't save it in Excel, though … the format will get messed up.

I haven't yet sifted these results w/ a fine-toothed comb. See what you find, and describe anything esp. interesting on the Discussion Board. Words like "wild," "dark," and "face" tend to be a good place to start, at least for a Romanticist. 

I also think it's interesting to observe which topics sort out sharply by genre and which ones don't. A particularly odd case is topic #54 in the 19th-century model, which is mostly fiction -- but also four works by Carlyle, and a biography of Carlyle, which are by far the most typical works in the topic. I don't know exactly what to make of that, although Carlyle does have a notoriously colorful diction …
