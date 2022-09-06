library(tidyverse)


hamlet = readLines(here::here("examples/week2/hamlet.txt")) |>
  discard(~ . == "")

head(hamlet)


# map step

word_count = function(line) {
  line %>%
    tolower() %>%
    str_replace_all("[^a-z ]", "") |>
    {\(x) str_split(x, " ")[[1]]}() |>
    str_trim() %>%
    discard(~ . == "") |>
    table() |>
    as.list()
}

word_count(hamlet[1]) |> str()

map_res = map(hamlet, word_count)

map_res |> head(n=3) |> str()


# shuffle step

map_res_flat = flatten(map_res)
map_res_flat |> head(n=10) |> str()

keys = names(map_res_flat) %>% unique()
shuf_res = map(
  keys, 
  function(key)  
    map_res_flat[names(map_res_flat) == key] |> unlist() |> set_names(NULL)
) |>
  set_names(keys)


## Reduce step

reduce_res = map(shuf_res, sum)


## Make data frame

( d = tibble(
    keys = names(reduce_res), 
    values = unlist(reduce_res)
  ) |>
    arrange(desc(values))
)


## K Means

set.seed(123)

kmeans = tibble(
  x = c(rnorm(30, -1, 0.3), rnorm(30, 0, 0.3), rnorm(30, 1.5, 0.3)),
  true_label = rep(as.character(1:3), c(30,30,30)),
  label = sample(as.character(1:3), size=3*30, replace=TRUE)
)

ggplot(kmeans, aes(x = x, fill=true_label)) +
  geom_density(alpha=0.5) +
  labs(title="True labels")

ggplot(kmeans, aes(x = x, fill=label)) +
  geom_density(alpha=0.5) +
  labs(title="Est labels")

ctr_init = list(-0.3, 0, 0.3) %>% set_names(1:3)


res = list()
ctr = ctr_init
for(i in 1:10) {
  map_func = function(obs, ctr) {
    label = which.min(abs(obs-unlist(ctr)))
    list(obs) |> set_names(label)
  }
  
  map_res = map(kmeans$x, map_func, ctr=ctr) |> 
    flatten()
  
  keys = names(ctr)
  shuf_res = map(
    keys, 
    function(key)  
      map_res[names(map_res) == key] |> 
        unlist() |>
        set_names(NULL)
  ) %>% 
    set_names(keys)
  
  reduce_res = map_dbl(shuf_res, mean)
  
  
  # Centroids
  ctr = reduce_res
  res[[i]] = ctr
  
}

bind_rows(res)

map2_dfr(
  shuf_res, names(shuf_res),
  ~ tibble(
    x = .x,
    label = .y
  )
) |>
  ggplot(aes(x = x, fill=label)) +
  geom_density(alpha=0.5) +
  labs(title="Est labels")
